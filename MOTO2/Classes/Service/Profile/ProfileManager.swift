//
//  ProfileManagerCore.swift
//  FNP
//
//  Created by Andrey Chernyshev on 09.07.2021.
//

import RxSwift
import Foundation

protocol ProfileManagerProtocol {
    func set(
        motivation: Int?,
        examDate: Date?,
        testMode: TestMode?,
        testMinutes: Int?,
        testDaysOfWeek: [DayOfWeek]?,
        course: Course?,
        country: String?,
        state: String?,
        language: String?
    ) -> Single<Void>
    func obtainProfile(forceUpdate: Bool) -> Single<Profile?>
    func obtainLocale(forceUpdate: Bool) -> Single<ProfileLocale?>
    func obtainCountries(forceUpdate: Bool) -> Single<[Country]>
    func obtainReferenceDateOfExam() -> Single<Date?>
    func obtainDateOfExam(forceUpdate: Bool) -> Single<Date?>
    func obtainExamEnvironment() -> Single<ExamEnvironment?>
    func obtainTestMode(forceUpdate: Bool) -> Single<TestMode?>
    func obtainTestMinutes(forceUpdate: Bool) -> Single<Int?>
    func obtainTestDaysOfWeek() -> Single<[DayOfWeek]?>
    func syncTokens(oldToken: String, newToken: String) -> Single<Void>
    func login(userToken: String) -> Single<Void>
}

final class ProfileManager: ProfileManagerProtocol {
    enum Constants {
        static let referenceDateOfExamKey = "profile_manager_reference_date_of_exam_key"
        static let dateOfExamKey = "profile_manager_date_of_exam_key"
        static let examEnvironmentKey = "profile_manager_exam_environment_key"
        static let testModeKey = "profile_manager_test_mode_key"
        static let testMinutesKey = "profile_manager_test_minutes_key"
        static let testDaysOfWeekKey = "profile_manager_days_of_week_key"
        static let localeKey = "profile_manager_locale_key"
        static let countriesKey = "profile_manager_countries_key"
    }
    
    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
    
    private lazy var sessionManager = SessionManager()
}

// MARK: Study
extension ProfileManager {
    func set(
        motivation: Int? = nil,
        examDate: Date? = nil,
        testMode: TestMode? = nil,
        testMinutes: Int? = nil,
        testDaysOfWeek: [DayOfWeek]? = nil,
        course: Course? = nil,
        country: String? = nil,
        state: String? = nil,
        language: String? = nil
    ) -> Single<Void> {
        let request = SetRequest(
            userToken: sessionManager.internalId,
            country: country,
            state: state,
            language: language,
            level: motivation,
            testMode: testMode?.code(),
            examDate: examDateStringFormatted(examDate),
            testMinutes: testMinutes,
            courseId: course?.id
        )
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: { [weak self] in
                guard let self = self else { return }

                self.store(dateOfExam: examDate)
                self.store(testMode: testMode)
                self.store(testMinutes: testMinutes)
                self.store(testDaysOfWeek: testDaysOfWeek)
                self.store(course: course)
                self.store(countryCode: country, languageCode: language, stateCode: state)
            })
    }
    
    func obtainProfile(forceUpdate: Bool) -> Single<Profile?> {
        forceUpdate ? loadProfile() : cachedProfile()
    }
    
    func obtainLocale(forceUpdate: Bool) -> Single<ProfileLocale?> {
        forceUpdate ? loadLocale() : cachedLocale()
    }
    
    func obtainCountries(forceUpdate: Bool) -> Single<[Country]> {
        forceUpdate ? loadCountries() : cachedCountries()
    }
    
    func obtainReferenceDateOfExam() -> Single<Date?> {
        Single<Date?>
            .create { event in
                let date = UserDefaults.standard.value(forKey: Constants.referenceDateOfExamKey) as? Date
                
                event(.success(date))
                
                return Disposables.create()
            }
    }
    
    func obtainDateOfExam(forceUpdate: Bool) -> Single<Date?> {
        forceUpdate ? loadDateOfExam() : cachedDateOfExam()
    }
    
    func obtainExamEnvironment() -> Single<ExamEnvironment?> {
        Single<ExamEnvironment?>
            .create { event in
                let environment: ExamEnvironment? = {
                    guard let data = UserDefaults.standard.data(forKey: Constants.examEnvironmentKey) else { return nil }
                    return try? JSONDecoder().decode(ExamEnvironment.self, from: data)
                }()
                
                event(.success(environment))
                
                return Disposables.create()
            }
    }
    
    func obtainTestMode(forceUpdate: Bool) -> Single<TestMode?> {
        forceUpdate ? loadTestMode() : cachedTestMode()
    }
    
    func obtainTestMinutes(forceUpdate: Bool) -> Single<Int?> {
        forceUpdate ? loadTestMinutes() : cachedTestMinutes()
    }
    
    func obtainTestDaysOfWeek() -> Single<[DayOfWeek]?> {
        Single<[DayOfWeek]?>
            .create { event in
                guard
                    let data = UserDefaults.standard.data(forKey: Constants.testDaysOfWeekKey),
                    let testDaysOfWeek = try? JSONDecoder().decode([DayOfWeek].self, from: data)
                else {
                    event(.success(nil))
                    return Disposables.create()
                }
                
                event(.success(testDaysOfWeek))
                
                return Disposables.create()
            }
    }
    
    func syncTokens(oldToken: String, newToken: String) -> Single<Void> {
        let request = SyncTokensRequest(
            oldToken: oldToken,
            newToken: newToken
        )
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
    }
    
    func login(userToken: String) -> Single<Void> {
        let request = LoginRequest(userToken: userToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
    }
}

// MARK: Private
private extension ProfileManager {
    func cachedProfile() -> Single<Profile?> {
        let testMode = cachedTestMode()
        let testMinutes = cachedTestMinutes()
        let examDate = cachedDateOfExam()
        let examEnvironment = obtainExamEnvironment()
        let locale = cachedLocale()
        
        return Single
            .zip(
                testMode,
                testMinutes,
                examDate,
                examEnvironment,
                locale
            ) { testMode, testMinutes, examDate, examEnvironment, locale -> Profile in
                Profile(
                    testMode: testMode,
                    testMinutes: testMinutes,
                    examDate: examDate,
                    selectedCourse: examEnvironment?.course,
                    locale: locale
                )
            }
    }
    
    func loadProfile() -> Single<Profile?> {
        let request = GetProfileRequest(userToken: sessionManager.internalId)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetProfileResponseMapper.map(from: $0) }
            .do(onSuccess: { [weak self] profile in
                guard let self = self, let profile = profile else {
                    return
                }

                self.store(testMode: profile.testMode)
                self.store(testMinutes: profile.testMinutes)
                self.store(dateOfExam: profile.examDate)
                self.store(course: profile.selectedCourse)
                self.store(
                    countryCode: profile.locale?.countryCode,
                    languageCode: profile.locale?.languageCode,
                    stateCode: profile.locale?.stateCode
                )
            })
    }
    
    func cachedLocale() -> Single<ProfileLocale?> {
        Single<ProfileLocale?>
            .create { event in
                guard
                    let data = UserDefaults.standard.data(forKey: Constants.localeKey),
                    let locale = try? JSONDecoder().decode(ProfileLocale.self, from: data)
                else {
                    event(.success(nil))
                    return Disposables.create()
                }

                event(.success(locale))
                
                return Disposables.create()
            }
    }
    
    func loadLocale() -> Single<ProfileLocale?> {
        loadProfile()
            .map { $0?.locale }
            .do(onSuccess: { [weak self] locale in
                guard let self = self, let locale = locale else {
                    return
                }
                
                self.store(countryCode: locale.countryCode,
                           languageCode: locale.languageCode,
                           stateCode: locale.stateCode)
            })
    }
    
    func store(countryCode: String?,
               languageCode: String?,
               stateCode: String?) {
        if countryCode == nil && languageCode == nil && stateCode == nil {
            return
        }
        
        let locale = ProfileLocale(countryCode: countryCode,
                                   languageCode: languageCode,
                                   stateCode: stateCode)
        
        guard let data = try? JSONEncoder().encode(locale) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: Constants.localeKey)
        
        ProfileMediator.shared.notifyAboutChanged(locale: locale)
    }
    
    func store(dateOfExam: Date?) {
        guard let dateOfExam = dateOfExam else {
            return
        }
        
        UserDefaults.standard.set(dateOfExam, forKey: Constants.dateOfExamKey)
        UserDefaults.standard.set(Date(), forKey: Constants.referenceDateOfExamKey)
        
        ProfileMediator.shared.notifyAboutChanged(dateOfExam: dateOfExam)
    }
    
    func cachedDateOfExam() -> Single<Date?> {
        Single<Date?>
            .create { event in
                guard let dateOfExam = UserDefaults.standard.value(forKey: Constants.dateOfExamKey) as? Date else {
                    event(.success(nil))
                    return Disposables.create()
                }
                
                event(.success(dateOfExam))
                
                return Disposables.create()
            }
    }
    
    func loadDateOfExam() -> Single<Date?> {
        loadProfile()
            .map { $0?.examDate }
            .do(onSuccess: { [weak self] dateOfExam in
                guard let self = self, let dateOfExam = dateOfExam else {
                    return
                }
                
                self.store(dateOfExam: dateOfExam)
            })
    }
    
    func store(course: Course?) {
        guard let course else { return }
        
        let environment = ExamEnvironment(course: course)
        
        guard let data = try? JSONEncoder().encode(environment) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: Constants.examEnvironmentKey)
        
        ProfileMediator.shared.notifyAboutChanged(examEnvironment: environment)
    }
    
    func cachedCountries() -> Single<[Country]> {
        Single<[Country]>
            .create { event in
                guard
                    let data = UserDefaults.standard.data(forKey: Constants.countriesKey),
                    let countries = try? JSONDecoder().decode([Country].self, from: data)
                else {
                    event(.success([]))
                    return Disposables.create()
                }
                
                event(.success(countries))
                
                return Disposables.create()
            }
    }
    
    func loadCountries() -> Single<[Country]> {
        defaultRequestWrapper
            .callServerApi(requestBody: GetCountriesRequest())
            .map { GetCountriesResponseMapper.map(from: $0) }
            .do(onSuccess: { [weak self] countries in
                guard let self = self else {
                    return
                }
                
                self.store(countries: countries)
            })
    }
    
    func store(countries: [Country]) {
        guard let data = try? JSONEncoder().encode(countries) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: Constants.countriesKey)
    }
    
    func store(testMode: TestMode?) {
        guard let testMode = testMode, let data = try? JSONEncoder().encode(testMode) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: Constants.testModeKey)
        
        ProfileMediator.shared.notifyAboutChanged(testMode: testMode)
    }
    
    func cachedTestMode() -> Single<TestMode?> {
        Single<TestMode?>
            .create { event in
                guard
                    let data = UserDefaults.standard.data(forKey: Constants.testModeKey),
                    let mode = try? JSONDecoder().decode(TestMode.self, from: data)
                else {
                    event(.success(nil))
                    return Disposables.create()
                }

                event(.success(mode))
                
                return Disposables.create()
            }
    }
    
    func loadTestMode() -> Single<TestMode?> {
        loadProfile()
            .map { $0?.testMode }
            .do(onSuccess: { [weak self] testMode in
                guard let self = self, let testMode = testMode else {
                    return
                }
                
                self.store(testMode: testMode)
            })
    }
    
    func store(testMinutes: Int?) {
        guard let testMinutes = testMinutes else {
            return
        }

        UserDefaults.standard.set(testMinutes, forKey: Constants.testMinutesKey)
        
        ProfileMediator.shared.notifyAboutChanged(testMinutes: testMinutes)
    }
    
    func cachedTestMinutes() -> Single<Int?> {
        Single<Int?>
            .create { event in
                guard let testMinutes = UserDefaults.standard.value(forKey: Constants.testMinutesKey) as? Int else {
                    event(.success(nil))
                    return Disposables.create()
                }
                
                event(.success(testMinutes))
                
                return Disposables.create()
            }
    }
    
    func loadTestMinutes() -> Single<Int?> {
        loadProfile()
            .map { $0?.testMinutes }
            .do(onSuccess: { [weak self] testMinutes in
                guard let self = self, let testMinutes = testMinutes else {
                    return
                }
                
                self.store(testMinutes: testMinutes)
            })
    }
    
    func store(testDaysOfWeek: [DayOfWeek]?) {
        guard
            let testDaysOfWeek = testDaysOfWeek,
            let data = try? JSONEncoder().encode(testDaysOfWeek)
        else {
            return
        }

        UserDefaults.standard.set(data, forKey: Constants.testDaysOfWeekKey)
        
        ProfileMediator.shared.notifyAboutChanged(testDaysOfWeek: testDaysOfWeek)
    }
    
    func examDateStringFormatted(_ date: Date?) -> String? {
        guard let date = date else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale.current
        
        return formatter.string(from: date)
    }
}
