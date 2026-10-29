-- Połączenia między organizmami: klucze obce do tabel z innych organizmów.
-- Uruchom po plikach 01–18. Wygenerowane z narzedzia/organizmy.py.

-- organizm 2: API platformy
ALTER TABLE ORG02_PlatformAPI ADD CONSTRAINT ORG02_PlatformAPI_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES ORG01_SourcePlatform (SourcePlatformKey);

-- organizm 3: Endpointy i zwracane dane
ALTER TABLE ORG03_APIEndpoint ADD CONSTRAINT ORG03_APIEndpoint_APIVersion_FK FOREIGN KEY (APIVersionKey) REFERENCES ORG02_APIVersion (APIVersionKey);
ALTER TABLE ORG03_EndpointResponse ADD CONSTRAINT ORG03_EndpointResponse_DataFormat_FK FOREIGN KEY (DataFormatKey) REFERENCES ORG02_DataFormat (DataFormatKey);

-- organizm 4: Odbiór danych z platformy
ALTER TABLE ORG04_DataDelivery ADD CONSTRAINT ORG04_DataDelivery_APIEndpoint_FK FOREIGN KEY (APIEndpointKey) REFERENCES ORG03_APIEndpoint (APIEndpointKey);

-- organizm 5: Konto firmy na platformie
ALTER TABLE ORG05_EmployerAccount ADD CONSTRAINT ORG05_EmployerAccount_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES ORG01_SourcePlatform (SourcePlatformKey);
ALTER TABLE ORG05_EmployerAccountVersion ADD CONSTRAINT ORG05_EmployerAccountVersion_RawRecord_FK FOREIGN KEY (RawRecordKey) REFERENCES ORG04_RawRecord (RawRecordKey);

-- organizm 6: Firma w rejestrach publicznych
ALTER TABLE ORG06_Employer ADD CONSTRAINT ORG06_Employer_Country_FK FOREIGN KEY (CountryKey) REFERENCES ORG01_Country (CountryKey);

-- organizm 7: Powiązanie kont z firmą
ALTER TABLE ORG07_AccountEmployerLink ADD CONSTRAINT ORG07_AccountEmployerLink_EmployerAccount_FK FOREIGN KEY (EmployerAccountKey) REFERENCES ORG05_EmployerAccount (EmployerAccountKey);
ALTER TABLE ORG07_AccountEmployerLink ADD CONSTRAINT ORG07_AccountEmployerLink_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES ORG06_Employer (EmployerKey);
ALTER TABLE ORG07_AgencyClient ADD CONSTRAINT ORG07_AgencyClient_AgencyEmployerKey_FK FOREIGN KEY (AgencyEmployerKey) REFERENCES ORG06_Employer (EmployerKey);
ALTER TABLE ORG07_AgencyClient ADD CONSTRAINT ORG07_AgencyClient_ClientEmployerKey_FK FOREIGN KEY (ClientEmployerKey) REFERENCES ORG06_Employer (EmployerKey);

-- organizm 8: Ogłoszenie i miejsce pracy
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_EmployerAccount_FK FOREIGN KEY (EmployerAccountKey) REFERENCES ORG05_EmployerAccount (EmployerAccountKey);
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_RawRecord_FK FOREIGN KEY (RawRecordKey) REFERENCES ORG04_RawRecord (RawRecordKey);
ALTER TABLE ORG08_Location ADD CONSTRAINT ORG08_Location_Country_FK FOREIGN KEY (CountryKey) REFERENCES ORG01_Country (CountryKey);

-- organizm 9: Warunki zatrudnienia
ALTER TABLE ORG09_PostingSalary ADD CONSTRAINT ORG09_PostingSalary_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG09_PostingBenefit ADD CONSTRAINT ORG09_PostingBenefit_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);

-- organizm 10: Wymagania i obowiązki
ALTER TABLE ORG10_PostingResponsibility ADD CONSTRAINT ORG10_PostingResponsibility_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG10_PostingRequirement ADD CONSTRAINT ORG10_PostingRequirement_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);

-- organizm 11: Historia i treść ogłoszenia
ALTER TABLE ORG11_PostingEvent ADD CONSTRAINT ORG11_PostingEvent_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG11_PostingEvent ADD CONSTRAINT ORG11_PostingEvent_DataDelivery_FK FOREIGN KEY (DataDeliveryKey) REFERENCES ORG04_DataDelivery (DataDeliveryKey);
ALTER TABLE ORG11_PostingVersion ADD CONSTRAINT ORG11_PostingVersion_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG11_BoilerplatePattern ADD CONSTRAINT ORG11_BoilerplatePattern_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES ORG06_Employer (EmployerKey);

-- organizm 12: Podobne ogłoszenia i rodziny
ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_FirstJobPostingKey_FK FOREIGN KEY (FirstJobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_SecondJobPostingKey_FK FOREIGN KEY (SecondJobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG12_FamilyMember ADD CONSTRAINT ORG12_FamilyMember_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG12_PostingFamily ADD CONSTRAINT ORG12_PostingFamily_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES ORG06_Employer (EmployerKey);

-- organizm 13: Kandydat, aplikacje i zgody
ALTER TABLE ORG13_CandidatePseudonym ADD CONSTRAINT ORG13_CandidatePseudonym_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES ORG01_SourcePlatform (SourcePlatformKey);
ALTER TABLE ORG13_Application ADD CONSTRAINT ORG13_Application_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG13_Application ADD CONSTRAINT ORG13_Application_DataDelivery_FK FOREIGN KEY (DataDeliveryKey) REFERENCES ORG04_DataDelivery (DataDeliveryKey);

-- organizm 14: Zgłoszenie wyniku rekrutacji
ALTER TABLE ORG14_RecruitmentReport ADD CONSTRAINT ORG14_RecruitmentReport_CandidatePseudonym_FK FOREIGN KEY (CandidatePseudonymKey) REFERENCES ORG13_CandidatePseudonym (CandidatePseudonymKey);
ALTER TABLE ORG14_RecruitmentReport ADD CONSTRAINT ORG14_RecruitmentReport_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG14_Reminder ADD CONSTRAINT ORG14_Reminder_Application_FK FOREIGN KEY (ApplicationKey) REFERENCES ORG13_Application (ApplicationKey);

-- organizm 15: Weryfikacja zgłoszenia
ALTER TABLE ORG15_ReportCheck ADD CONSTRAINT ORG15_ReportCheck_RecruitmentReport_FK FOREIGN KEY (RecruitmentReportKey) REFERENCES ORG14_RecruitmentReport (RecruitmentReportKey);
ALTER TABLE ORG15_ReportVerdict ADD CONSTRAINT ORG15_ReportVerdict_RecruitmentReport_FK FOREIGN KEY (RecruitmentReportKey) REFERENCES ORG14_RecruitmentReport (RecruitmentReportKey);
ALTER TABLE ORG15_ReportDevice ADD CONSTRAINT ORG15_ReportDevice_RecruitmentReport_FK FOREIGN KEY (RecruitmentReportKey) REFERENCES ORG14_RecruitmentReport (RecruitmentReportKey);

-- organizm 16: Wykrywanie nadużyć
ALTER TABLE ORG16_AbuseAlert ADD CONSTRAINT ORG16_AbuseAlert_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES ORG06_Employer (EmployerKey);
ALTER TABLE ORG16_AlertReport ADD CONSTRAINT ORG16_AlertReport_RecruitmentReport_FK FOREIGN KEY (RecruitmentReportKey) REFERENCES ORG14_RecruitmentReport (RecruitmentReportKey);

-- organizm 17: Sygnały o firmie
ALTER TABLE ORG17_SignalSnapshot ADD CONSTRAINT ORG17_SignalSnapshot_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES ORG06_Employer (EmployerKey);

-- organizm 18: Trust Score i publikacja
ALTER TABLE ORG18_ScoringWeight ADD CONSTRAINT ORG18_ScoringWeight_SignalType_FK FOREIGN KEY (SignalTypeKey) REFERENCES ORG17_SignalType (SignalTypeKey);
ALTER TABLE ORG18_TrustScore ADD CONSTRAINT ORG18_TrustScore_SignalSnapshot_FK FOREIGN KEY (SignalSnapshotKey) REFERENCES ORG17_SignalSnapshot (SignalSnapshotKey);
ALTER TABLE ORG18_ScoreReason ADD CONSTRAINT ORG18_ScoreReason_SignalType_FK FOREIGN KEY (SignalTypeKey) REFERENCES ORG17_SignalType (SignalTypeKey);
