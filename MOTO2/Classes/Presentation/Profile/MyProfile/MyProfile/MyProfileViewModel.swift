//
//  MyProfileViewModel.swift
//  ITExams
//
//  Created by Андрей Чернышев on 13.05.2022.
//

import RxSwift
import RxCocoa

final class MyProfileViewModel {
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    lazy var resetStats = PublishRelay<Void>()
    
    lazy var elements = makeElements()
    
    private lazy var dateOfExam = makeDateOfExam()
    private lazy var examEnvironment = makeExamEnvironment()
    private lazy var studyMode = makeStudyMode()
    private lazy var dailyGoal = makeDailyGoal()
    private lazy var resetedStats = makeResetStats()
    private lazy var countries = makeCountries()
    private lazy var locale = makeLocale()
    
    private lazy var profileManager = ProfileManager()
    private lazy var statsManager = StatsManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Private
private extension MyProfileViewModel {
    func makeElements() -> Driver<[MyProfileTableElement]> {
        Driver
            .combineLatest(
                dateOfExam,
                examEnvironment,
                studyMode,
                dailyGoal,
                resetedStats,
                locale
            )
            .map { stub -> [MyProfileTableElement] in
                let (dateOfExam, examEnvironment, studyMode, dailyGoal, resetedStats, locale) = stub
                
                return [
                    .dateOfExam(dateOfExam),
                    .locale(locale ?? ""),
                    .course(examEnvironment?.course.name ?? ""),
                    .studyMode(studyMode),
                    .dailyGoal(dailyGoal),
                    .resetProgress(resetedStats)
                ]
            }
    }
    
    func makeDateOfExam() -> Driver<String> {
        let initial = profileManager
            .obtainDateOfExam(forceUpdate: false)
            .asDriver(onErrorJustReturn: nil)
        
        let updated = ProfileMediator.shared
            .changedDateOfExam
            .map { date -> Date? in
                date
            }
            .asDriver(onErrorJustReturn: nil)
        
        return Driver
            .merge(initial, updated)
            .map { date -> String in
                guard let date = date else {
                    return ""
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM dd, yyyy"
                formatter.locale = Locale.current
                return formatter.string(from: date)
            }
    }
    
    func makeLocale() -> Driver<String?> {
        let initial = profileManager
            .obtainLocale(forceUpdate: false)
            .asDriver(onErrorJustReturn: nil)
        
        let updated = ProfileMediator.shared
            .changedLocale
            .map { locale -> ProfileLocale? in
                locale
            }
            .asDriver(onErrorJustReturn: nil)
        
        let locale =  Driver
            .merge(initial, updated)
        
        return Driver
            .combineLatest(locale, countries)
            .map { locale, countries -> String? in
                guard let locale else { return nil }
                
                let country: Country? = {
                    guard let countryCode = locale.countryCode else { return nil }
                    return countries.first(where: { $0.code == countryCode })
                }()
                
                let language: Language? = {
                    guard let languageCode = locale.languageCode else { return nil }
                    return country?.languages.first(where: { $0.code == languageCode })
                }()
                
                let state: State? = {
                    guard let stateCode = locale.stateCode else { return nil }
                    return language?.states.first(where: { $0.code == stateCode })
                }()
                
                let strings = [country?.name, language?.name, state?.name].compactMap { $0 }
                
                guard !strings.isEmpty else { return nil }
                
                return strings.joined(separator: ", ")
            }
    }
    
    func makeCourse() -> Driver<Course?> {
        examEnvironment.map { $0?.course }
    }
    
    func makeExamEnvironment() -> Driver<ExamEnvironment?> {
        let initial = profileManager
            .obtainExamEnvironment()
            .asDriver(onErrorJustReturn: nil)
        
        let updated = ProfileMediator.shared
            .changedExamEnvironment
            .map { examEnvironment -> ExamEnvironment? in
                examEnvironment
            }
            .asDriver(onErrorJustReturn: nil)
        
        return Driver.merge(initial, updated)
    }
    
    func makeStudyMode() -> Driver<String> {
        let initial = profileManager
            .obtainTestMode(forceUpdate: false)
            .asDriver(onErrorJustReturn: nil)
        
        let updated = ProfileMediator.shared
            .changedTestMode
            .map { mode -> TestMode? in
                mode
            }
            .asDriver(onErrorJustReturn: nil)
        
        return Driver
            .merge(initial, updated)
            .map { mode -> String in
                guard let mode = mode else {
                    return ""
                }
                
                switch mode {
                case .noExplanations:
                    return "MyProfile.StudyMode.WithoutExplanations".localized
                case .fullComplect:
                    return "MyProfile.StudyMode.FullSupport".localized
                case .onAnExam:
                    return "MyProfile.StudyMode.Exam-style".localized
                }
            }
    }
    
    func makeDailyGoal() -> Driver<String> {
        let initial = profileManager
            .obtainTestMinutes(forceUpdate: false)
            .asDriver(onErrorJustReturn: nil)
        
        let updated = ProfileMediator.shared
            .changedTestMinutes
            .map { testMinutes -> Int? in
                testMinutes
            }
            .asDriver(onErrorJustReturn: nil)
        
        return Driver.merge(initial, updated)
            .map { testMinutes -> String in
                guard let testMinutes = testMinutes else {
                    return ""
                }
                
                return String(format: "MyProfile.min".localized, testMinutes)
            }
    }
    
    func makeResetStats() -> Driver<Bool> {
        let start = resetStats.map { true }
        
        let action = resetStats
            .withLatestFrom(examEnvironment)
            .flatMapLatest { [weak self] examEnvironment -> Observable<Bool> in
                guard let self = self, let examEnvironment = examEnvironment else {
                    return .never()
                }

                func source() -> Single<Void> {
                    self.statsManager
                        .resetStats(courseId: examEnvironment.course.id)
                }

                func trigger(error: Error) -> Observable<Void> {
                    guard let tryAgain = self.tryAgain?(error) else {
                        return .empty()
                    }

                    return tryAgain
                }

                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { trigger(error: $0) })
                    .asObservable()
                    .map { false }
            }
        
        return Observable
            .merge(start, action)
            .asDriver(onErrorJustReturn: false)
            .startWith(false)
    }
    
    func makeCountries() -> Driver<[Country]> {
        profileManager
            .obtainCountries(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
}
