-- Organizm 8: Ogłoszenie i miejsce pracy
-- Samo ogłoszenie: kto je opublikował, kiedy, na jakim poziomie, w jakim trybie i w których miastach.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE PostingStatus (
    PostingStatusKey   NUMBER(2)     NOT NULL,
    PostingStatusName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE SeniorityLevel (
    SeniorityLevelKey   NUMBER(2)     NOT NULL,
    SeniorityLevelName  VARCHAR2(40)  NOT NULL,
    SeniorityRank       NUMBER(2)     NOT NULL
);

CREATE TABLE JobPosting (
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

CREATE TABLE WorkMode (
    WorkModeKey   NUMBER(2)     NOT NULL,
    WorkModeName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE PostingLocation (
    PostingLocationKey  NUMBER(11)  NOT NULL,
    JobPostingKey       NUMBER(10)  NOT NULL,
    LocationKey         NUMBER(6)   NOT NULL,
    IsMainLocation      CHAR(1)     NOT NULL
);

CREATE TABLE Location (
    LocationKey  NUMBER(6)     NOT NULL,
    CityName     VARCHAR2(80)  NOT NULL,
    RegionName   VARCHAR2(80),
    CountryKey   NUMBER(3)     NOT NULL
);

COMMENT ON TABLE PostingStatus IS 'Stan ogłoszenia.';
COMMENT ON COLUMN PostingStatus.PostingStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN PostingStatus.PostingStatusName IS 'Nazwa stanu';

COMMENT ON TABLE SeniorityLevel IS 'Poziom stanowiska.';
COMMENT ON COLUMN SeniorityLevel.SeniorityLevelKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN SeniorityLevel.SeniorityLevelName IS 'Nazwa poziomu';
COMMENT ON COLUMN SeniorityLevel.SeniorityRank IS 'Kolejność poziomów (1 = najniższy)';

COMMENT ON TABLE JobPosting IS 'Ogłoszenie o pracę opublikowane przez konto na platformie.';
COMMENT ON COLUMN JobPosting.JobPostingKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN JobPosting.EmployerAccountKey IS 'Konto, które opublikowało ogłoszenie';
COMMENT ON COLUMN JobPosting.ExternalPostingId IS 'Numer ogłoszenia w serwisie';
COMMENT ON COLUMN JobPosting.PostingTitle IS 'Tytuł (aktualny)';
COMMENT ON COLUMN JobPosting.PostingStatusKey IS 'Stan ogłoszenia';
COMMENT ON COLUMN JobPosting.SeniorityLevelKey IS 'Poziom stanowiska (bywa niepodany)';
COMMENT ON COLUMN JobPosting.WorkModeKey IS 'Tryb pracy (bywa niepodany)';
COMMENT ON COLUMN JobPosting.VacancyCount IS 'Ilu osób szuka';
COMMENT ON COLUMN JobPosting.PublishedDate IS 'Data pierwszej publikacji';
COMMENT ON COLUMN JobPosting.ExpiryDate IS 'Planowana data końca';
COMMENT ON COLUMN JobPosting.RawRecordKey IS 'Rekord, z którego powstało ogłoszenie';

COMMENT ON TABLE WorkMode IS 'Tryb pracy.';
COMMENT ON COLUMN WorkMode.WorkModeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN WorkMode.WorkModeName IS 'Nazwa trybu pracy';

COMMENT ON TABLE PostingLocation IS 'Miejsce pracy w ogłoszeniu – tabela łącząca ogłoszenia z miejscowościami.';
COMMENT ON COLUMN PostingLocation.PostingLocationKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN PostingLocation.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN PostingLocation.LocationKey IS 'Miejscowość';
COMMENT ON COLUMN PostingLocation.IsMainLocation IS 'Czy to główne miejsce pracy';

COMMENT ON TABLE Location IS 'Miejscowość.';
COMMENT ON COLUMN Location.LocationKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN Location.CityName IS 'Miejscowość';
COMMENT ON COLUMN Location.RegionName IS 'Województwo albo region';
COMMENT ON COLUMN Location.CountryKey IS 'Kraj';

ALTER TABLE PostingStatus ADD CONSTRAINT PostingStatus_PK PRIMARY KEY (PostingStatusKey);
ALTER TABLE PostingStatus ADD CONSTRAINT PostingStatus_PostingStatusName_UN UNIQUE (PostingStatusName);
ALTER TABLE SeniorityLevel ADD CONSTRAINT SeniorityLevel_PK PRIMARY KEY (SeniorityLevelKey);
ALTER TABLE SeniorityLevel ADD CONSTRAINT SeniorityLevel_SeniorityLevelName_UN UNIQUE (SeniorityLevelName);
ALTER TABLE JobPosting ADD CONSTRAINT JobPosting_PK PRIMARY KEY (JobPostingKey);
ALTER TABLE JobPosting ADD CONSTRAINT JobPosting_UN UNIQUE (EmployerAccountKey, ExternalPostingId);
ALTER TABLE JobPosting ADD CONSTRAINT JobPosting_CK1 CHECK (ExpiryDate IS NULL OR ExpiryDate >= PublishedDate);
ALTER TABLE JobPosting ADD CONSTRAINT JobPosting_CK2 CHECK (VacancyCount > 0);
ALTER TABLE WorkMode ADD CONSTRAINT WorkMode_PK PRIMARY KEY (WorkModeKey);
ALTER TABLE WorkMode ADD CONSTRAINT WorkMode_WorkModeName_UN UNIQUE (WorkModeName);
ALTER TABLE PostingLocation ADD CONSTRAINT PostingLocation_PK PRIMARY KEY (PostingLocationKey);
ALTER TABLE PostingLocation ADD CONSTRAINT PostingLocation_UN UNIQUE (JobPostingKey, LocationKey);
ALTER TABLE PostingLocation ADD CONSTRAINT PostingLocation_IsMainLocation_CK CHECK (IsMainLocation IN ('T', 'N'));
ALTER TABLE Location ADD CONSTRAINT Location_PK PRIMARY KEY (LocationKey);
ALTER TABLE Location ADD CONSTRAINT Location_UN UNIQUE (CityName, RegionName, CountryKey);

ALTER TABLE JobPosting ADD CONSTRAINT JobPosting_PostingStatus_FK FOREIGN KEY (PostingStatusKey) REFERENCES PostingStatus (PostingStatusKey);
ALTER TABLE JobPosting ADD CONSTRAINT JobPosting_SeniorityLevel_FK FOREIGN KEY (SeniorityLevelKey) REFERENCES SeniorityLevel (SeniorityLevelKey);
ALTER TABLE JobPosting ADD CONSTRAINT JobPosting_WorkMode_FK FOREIGN KEY (WorkModeKey) REFERENCES WorkMode (WorkModeKey);
ALTER TABLE PostingLocation ADD CONSTRAINT PostingLocation_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES JobPosting (JobPostingKey);
ALTER TABLE PostingLocation ADD CONSTRAINT PostingLocation_Location_FK FOREIGN KEY (LocationKey) REFERENCES Location (LocationKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO PostingStatus (PostingStatusKey, PostingStatusName) VALUES (1, 'Aktywne');
INSERT INTO PostingStatus (PostingStatusKey, PostingStatusName) VALUES (2, 'Wygasłe');
INSERT INTO PostingStatus (PostingStatusKey, PostingStatusName) VALUES (3, 'Zamknięte przed terminem');
INSERT INTO PostingStatus (PostingStatusKey, PostingStatusName) VALUES (4, 'Usunięte przez platformę');
INSERT INTO PostingStatus (PostingStatusKey, PostingStatusName) VALUES (5, 'Wstrzymane');
INSERT INTO SeniorityLevel (SeniorityLevelKey, SeniorityLevelName, SeniorityRank) VALUES (1, 'Stażysta', 1);
INSERT INTO SeniorityLevel (SeniorityLevelKey, SeniorityLevelName, SeniorityRank) VALUES (2, 'Junior', 2);
INSERT INTO SeniorityLevel (SeniorityLevelKey, SeniorityLevelName, SeniorityRank) VALUES (3, 'Mid (samodzielny)', 3);
INSERT INTO SeniorityLevel (SeniorityLevelKey, SeniorityLevelName, SeniorityRank) VALUES (4, 'Senior', 4);
INSERT INTO SeniorityLevel (SeniorityLevelKey, SeniorityLevelName, SeniorityRank) VALUES (5, 'Ekspert', 5);
INSERT INTO SeniorityLevel (SeniorityLevelKey, SeniorityLevelName, SeniorityRank) VALUES (6, 'Kierownik', 6);
INSERT INTO WorkMode (WorkModeKey, WorkModeName) VALUES (1, 'Stacjonarna');
INSERT INTO WorkMode (WorkModeKey, WorkModeName) VALUES (2, 'Hybrydowa');
INSERT INTO WorkMode (WorkModeKey, WorkModeName) VALUES (3, 'Zdalna');
INSERT INTO WorkMode (WorkModeKey, WorkModeName) VALUES (4, 'W terenie');
COMMIT;
