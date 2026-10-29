-- Połączenia między organizmami: klucze obce do tabel z innych organizmów.
-- Uruchom po plikach 01–18. Wygenerowane z narzedzia/organizmy.py.

-- organizm 2: API platformy
ALTER TABLE PlatformAPI ADD CONSTRAINT PlatformAPI_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES SourcePlatform (SourcePlatformKey);

-- organizm 3: Endpointy i zwracane dane
ALTER TABLE APIEndpoint ADD CONSTRAINT APIEndpoint_APIVersion_FK FOREIGN KEY (APIVersionKey) REFERENCES APIVersion (APIVersionKey);
ALTER TABLE EndpointResponse ADD CONSTRAINT EndpointResponse_DataFormat_FK FOREIGN KEY (DataFormatKey) REFERENCES DataFormat (DataFormatKey);

-- organizm 4: Odbiór danych z platformy
ALTER TABLE DataDelivery ADD CONSTRAINT DataDelivery_APIEndpoint_FK FOREIGN KEY (APIEndpointKey) REFERENCES APIEndpoint (APIEndpointKey);

-- organizm 5: Konto firmy na platformie
ALTER TABLE EmployerAccount ADD CONSTRAINT EmployerAccount_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES SourcePlatform (SourcePlatformKey);
ALTER TABLE EmployerAccountVersion ADD CONSTRAINT EmployerAccountVersion_RawRecord_FK FOREIGN KEY (RawRecordKey) REFERENCES RawRecord (RawRecordKey);

-- organizm 6: Firma w rejestrach publicznych
ALTER TABLE Employer ADD CONSTRAINT Employer_Country_FK FOREIGN KEY (CountryKey) REFERENCES Country (CountryKey);

-- organizm 7: Powiązanie kont z firmą
ALTER TABLE AccountEmployerLink ADD CONSTRAINT AccountEmployerLink_EmployerAccount_FK FOREIGN KEY (EmployerAccountKey) REFERENCES EmployerAccount (EmployerAccountKey);
ALTER TABLE AccountEmployerLink ADD CONSTRAINT AccountEmployerLink_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES Employer (EmployerKey);
ALTER TABLE AgencyClient ADD CONSTRAINT AgencyClient_AgencyEmployerKey_FK FOREIGN KEY (AgencyEmployerKey) REFERENCES Employer (EmployerKey);
ALTER TABLE AgencyClient ADD CONSTRAINT AgencyClient_ClientEmployerKey_FK FOREIGN KEY (ClientEmployerKey) REFERENCES Employer (EmployerKey);

-- organizm 8: Ogłoszenie i miejsce pracy
ALTER TABLE JobPosting ADD CONSTRAINT JobPosting_EmployerAccount_FK FOREIGN KEY (EmployerAccountKey) REFERENCES EmployerAccount (EmployerAccountKey);
ALTER TABLE JobPosting ADD CONSTRAINT JobPosting_RawRecord_FK FOREIGN KEY (RawRecordKey) REFERENCES RawRecord (RawRecordKey);
ALTER TABLE Location ADD CONSTRAINT Location_Country_FK FOREIGN KEY (CountryKey) REFERENCES Country (CountryKey);

-- organizm 9: Warunki zatrudnienia
ALTER TABLE PostingSalary ADD CONSTRAINT PostingSalary_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES JobPosting (JobPostingKey);
ALTER TABLE PostingBenefit ADD CONSTRAINT PostingBenefit_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES JobPosting (JobPostingKey);

-- organizm 10: Wymagania i obowiązki
ALTER TABLE PostingResponsibility ADD CONSTRAINT PostingResponsibility_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES JobPosting (JobPostingKey);
ALTER TABLE PostingRequirement ADD CONSTRAINT PostingRequirement_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES JobPosting (JobPostingKey);

-- organizm 11: Historia i treść ogłoszenia
ALTER TABLE PostingEvent ADD CONSTRAINT PostingEvent_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES JobPosting (JobPostingKey);
ALTER TABLE PostingEvent ADD CONSTRAINT PostingEvent_DataDelivery_FK FOREIGN KEY (DataDeliveryKey) REFERENCES DataDelivery (DataDeliveryKey);
ALTER TABLE PostingVersion ADD CONSTRAINT PostingVersion_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES JobPosting (JobPostingKey);
ALTER TABLE BoilerplatePattern ADD CONSTRAINT BoilerplatePattern_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES Employer (EmployerKey);

-- organizm 12: Podobne ogłoszenia i rodziny
ALTER TABLE SimilarityPair ADD CONSTRAINT SimilarityPair_FirstJobPostingKey_FK FOREIGN KEY (FirstJobPostingKey) REFERENCES JobPosting (JobPostingKey);
ALTER TABLE SimilarityPair ADD CONSTRAINT SimilarityPair_SecondJobPostingKey_FK FOREIGN KEY (SecondJobPostingKey) REFERENCES JobPosting (JobPostingKey);
ALTER TABLE FamilyMember ADD CONSTRAINT FamilyMember_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES JobPosting (JobPostingKey);
ALTER TABLE PostingFamily ADD CONSTRAINT PostingFamily_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES Employer (EmployerKey);

-- organizm 13: Kandydat, aplikacje i zgody
ALTER TABLE CandidatePseudonym ADD CONSTRAINT CandidatePseudonym_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES SourcePlatform (SourcePlatformKey);
ALTER TABLE Application ADD CONSTRAINT Application_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES JobPosting (JobPostingKey);
ALTER TABLE Application ADD CONSTRAINT Application_DataDelivery_FK FOREIGN KEY (DataDeliveryKey) REFERENCES DataDelivery (DataDeliveryKey);

-- organizm 14: Zgłoszenie wyniku rekrutacji
ALTER TABLE RecruitmentReport ADD CONSTRAINT RecruitmentReport_CandidatePseudonym_FK FOREIGN KEY (CandidatePseudonymKey) REFERENCES CandidatePseudonym (CandidatePseudonymKey);
ALTER TABLE RecruitmentReport ADD CONSTRAINT RecruitmentReport_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES JobPosting (JobPostingKey);
ALTER TABLE Reminder ADD CONSTRAINT Reminder_Application_FK FOREIGN KEY (ApplicationKey) REFERENCES Application (ApplicationKey);

-- organizm 15: Weryfikacja zgłoszenia
ALTER TABLE ReportCheck ADD CONSTRAINT ReportCheck_RecruitmentReport_FK FOREIGN KEY (RecruitmentReportKey) REFERENCES RecruitmentReport (RecruitmentReportKey);
ALTER TABLE ReportVerdict ADD CONSTRAINT ReportVerdict_RecruitmentReport_FK FOREIGN KEY (RecruitmentReportKey) REFERENCES RecruitmentReport (RecruitmentReportKey);
ALTER TABLE ReportDevice ADD CONSTRAINT ReportDevice_RecruitmentReport_FK FOREIGN KEY (RecruitmentReportKey) REFERENCES RecruitmentReport (RecruitmentReportKey);

-- organizm 16: Wykrywanie nadużyć
ALTER TABLE AbuseAlert ADD CONSTRAINT AbuseAlert_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES Employer (EmployerKey);
ALTER TABLE AlertReport ADD CONSTRAINT AlertReport_RecruitmentReport_FK FOREIGN KEY (RecruitmentReportKey) REFERENCES RecruitmentReport (RecruitmentReportKey);

-- organizm 17: Sygnały o firmie
ALTER TABLE SignalSnapshot ADD CONSTRAINT SignalSnapshot_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES Employer (EmployerKey);

-- organizm 18: Trust Score i publikacja
ALTER TABLE ScoringWeight ADD CONSTRAINT ScoringWeight_SignalType_FK FOREIGN KEY (SignalTypeKey) REFERENCES SignalType (SignalTypeKey);
ALTER TABLE TrustScore ADD CONSTRAINT TrustScore_SignalSnapshot_FK FOREIGN KEY (SignalSnapshotKey) REFERENCES SignalSnapshot (SignalSnapshotKey);
ALTER TABLE ScoreReason ADD CONSTRAINT ScoreReason_SignalType_FK FOREIGN KEY (SignalTypeKey) REFERENCES SignalType (SignalTypeKey);
