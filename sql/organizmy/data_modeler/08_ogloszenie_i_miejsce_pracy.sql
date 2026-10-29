-- Organizm 8: Ogłoszenie i miejsce pracy
-- Samo ogłoszenie: kto je opublikował, kiedy, na jakim poziomie, w jakim trybie i w których miastach.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG08_PostingStatus (
    PostingStatusKey   NUMBER(2)     NOT NULL,
    PostingStatusName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG08_SeniorityLevel (
    SeniorityLevelKey   NUMBER(2)     NOT NULL,
    SeniorityLevelName  VARCHAR2(40)  NOT NULL,
    SeniorityRank       NUMBER(2)     NOT NULL
);

CREATE TABLE ORG08_JobPosting (
    JobPostingKey       NUMBER(10)     NOT NULL,
    EmployerAccountKey  NUMBER(8)      NOT NULL,
    ExternalPostingId   VARCHAR2(50)   NOT NULL,
    PostingTitle        VARCHAR2(200)  NOT NULL,
    PostingStatusKey    NUMBER(2)      NOT NULL,
    SeniorityLevelKey   NUMBER(2),
    WorkModeKey         NUMBER(2),
    VacancyCount        NUMBER(3),
    PublishedDate       DATE           NOT NULL,
    ExpiryDate          DATE,
    RawRecordKey        NUMBER(12)
);

CREATE TABLE ORG08_WorkMode (
    WorkModeKey   NUMBER(2)     NOT NULL,
    WorkModeName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE ORG08_PostingLocation (
    PostingLocationKey  NUMBER(11)  NOT NULL,
    JobPostingKey       NUMBER(10)  NOT NULL,
    LocationKey         NUMBER(6)   NOT NULL,
    IsMainLocation      CHAR(1)     NOT NULL
);

CREATE TABLE ORG08_Location (
    LocationKey  NUMBER(6)     NOT NULL,
    CityName     VARCHAR2(80)  NOT NULL,
    RegionName   VARCHAR2(80),
    CountryKey   NUMBER(3)     NOT NULL
);

COMMENT ON TABLE ORG08_PostingStatus IS 'Stan ogłoszenia.';
COMMENT ON COLUMN ORG08_PostingStatus.PostingStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG08_PostingStatus.PostingStatusName IS 'Nazwa stanu';

COMMENT ON TABLE ORG08_SeniorityLevel IS 'Poziom stanowiska.';
COMMENT ON COLUMN ORG08_SeniorityLevel.SeniorityLevelKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG08_SeniorityLevel.SeniorityLevelName IS 'Nazwa poziomu';
COMMENT ON COLUMN ORG08_SeniorityLevel.SeniorityRank IS 'Kolejność poziomów (1 = najniższy)';

COMMENT ON TABLE ORG08_JobPosting IS 'Ogłoszenie o pracę opublikowane przez konto na platformie.';
COMMENT ON COLUMN ORG08_JobPosting.JobPostingKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG08_JobPosting.EmployerAccountKey IS 'Konto, które opublikowało ogłoszenie';
COMMENT ON COLUMN ORG08_JobPosting.ExternalPostingId IS 'Numer ogłoszenia w serwisie';
COMMENT ON COLUMN ORG08_JobPosting.PostingTitle IS 'Tytuł (aktualny)';
COMMENT ON COLUMN ORG08_JobPosting.PostingStatusKey IS 'Stan ogłoszenia';
COMMENT ON COLUMN ORG08_JobPosting.SeniorityLevelKey IS 'Poziom stanowiska (bywa niepodany)';
COMMENT ON COLUMN ORG08_JobPosting.WorkModeKey IS 'Tryb pracy (bywa niepodany)';
COMMENT ON COLUMN ORG08_JobPosting.VacancyCount IS 'Ilu osób szuka';
COMMENT ON COLUMN ORG08_JobPosting.PublishedDate IS 'Data pierwszej publikacji';
COMMENT ON COLUMN ORG08_JobPosting.ExpiryDate IS 'Planowana data końca';
COMMENT ON COLUMN ORG08_JobPosting.RawRecordKey IS 'Rekord, z którego powstało ogłoszenie';

COMMENT ON TABLE ORG08_WorkMode IS 'Tryb pracy.';
COMMENT ON COLUMN ORG08_WorkMode.WorkModeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG08_WorkMode.WorkModeName IS 'Nazwa trybu pracy';

COMMENT ON TABLE ORG08_PostingLocation IS 'Miejsce pracy w ogłoszeniu – tabela łącząca ogłoszenia z miejscowościami.';
COMMENT ON COLUMN ORG08_PostingLocation.PostingLocationKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG08_PostingLocation.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN ORG08_PostingLocation.LocationKey IS 'Miejscowość';
COMMENT ON COLUMN ORG08_PostingLocation.IsMainLocation IS 'Czy to główne miejsce pracy';

COMMENT ON TABLE ORG08_Location IS 'Miejscowość.';
COMMENT ON COLUMN ORG08_Location.LocationKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG08_Location.CityName IS 'Miejscowość';
COMMENT ON COLUMN ORG08_Location.RegionName IS 'Województwo albo region';
COMMENT ON COLUMN ORG08_Location.CountryKey IS 'Kraj';

ALTER TABLE ORG08_PostingStatus ADD CONSTRAINT ORG08_PostingStatus_PK PRIMARY KEY (PostingStatusKey);
ALTER TABLE ORG08_PostingStatus ADD CONSTRAINT ORG08_PostingStatus_PostingStatusName_UN UNIQUE (PostingStatusName);
ALTER TABLE ORG08_SeniorityLevel ADD CONSTRAINT ORG08_SeniorityLevel_PK PRIMARY KEY (SeniorityLevelKey);
ALTER TABLE ORG08_SeniorityLevel ADD CONSTRAINT ORG08_SeniorityLevel_SeniorityLevelName_UN UNIQUE (SeniorityLevelName);
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_PK PRIMARY KEY (JobPostingKey);
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_UN UNIQUE (EmployerAccountKey, ExternalPostingId);
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_CK1 CHECK (ExpiryDate IS NULL OR ExpiryDate >= PublishedDate);
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_CK2 CHECK (VacancyCount > 0);
ALTER TABLE ORG08_WorkMode ADD CONSTRAINT ORG08_WorkMode_PK PRIMARY KEY (WorkModeKey);
ALTER TABLE ORG08_WorkMode ADD CONSTRAINT ORG08_WorkMode_WorkModeName_UN UNIQUE (WorkModeName);
ALTER TABLE ORG08_PostingLocation ADD CONSTRAINT ORG08_PostingLocation_PK PRIMARY KEY (PostingLocationKey);
ALTER TABLE ORG08_PostingLocation ADD CONSTRAINT ORG08_PostingLocation_UN UNIQUE (JobPostingKey, LocationKey);
ALTER TABLE ORG08_PostingLocation ADD CONSTRAINT ORG08_PostingLocation_IsMainLocation_CK CHECK (IsMainLocation IN ('T', 'N'));
ALTER TABLE ORG08_Location ADD CONSTRAINT ORG08_Location_PK PRIMARY KEY (LocationKey);
ALTER TABLE ORG08_Location ADD CONSTRAINT ORG08_Location_UN UNIQUE (CityName, RegionName, CountryKey);

ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_PostingStatus_FK FOREIGN KEY (PostingStatusKey) REFERENCES ORG08_PostingStatus (PostingStatusKey);
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_SeniorityLevel_FK FOREIGN KEY (SeniorityLevelKey) REFERENCES ORG08_SeniorityLevel (SeniorityLevelKey);
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_WorkMode_FK FOREIGN KEY (WorkModeKey) REFERENCES ORG08_WorkMode (WorkModeKey);
ALTER TABLE ORG08_PostingLocation ADD CONSTRAINT ORG08_PostingLocation_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG08_PostingLocation ADD CONSTRAINT ORG08_PostingLocation_Location_FK FOREIGN KEY (LocationKey) REFERENCES ORG08_Location (LocationKey);
