-- Organizm 13: Kandydat, aplikacje i zgody
-- Osoba znana tylko z pseudonimu, jej aplikacje potwierdzone przez platformę i jej zgody.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE CandidatePseudonym (
    CandidatePseudonymKey  NUMBER(10)    NOT NULL,
    SourcePlatformKey      NUMBER(4)     NOT NULL,
    PseudonymValue         VARCHAR2(64)  NOT NULL,
    FirstSeenAt            TIMESTAMP     NOT NULL
);

CREATE TABLE Application (
    ApplicationKey         NUMBER(12)  NOT NULL,
    CandidatePseudonymKey  NUMBER(10)  NOT NULL,
    JobPostingKey          NUMBER(10)  NOT NULL,
    AppliedAt              TIMESTAMP   NOT NULL,
    DataDeliveryKey        NUMBER(10)
);

CREATE TABLE Consent (
    ConsentKey             NUMBER(11)  NOT NULL,
    CandidatePseudonymKey  NUMBER(10)  NOT NULL,
    ConsentTextVersionKey  NUMBER(4)   NOT NULL,
    IsGranted              CHAR(1)     NOT NULL,
    DecidedAt              TIMESTAMP   NOT NULL
);

CREATE TABLE ApplicationStatusChange (
    ApplicationStatusChangeKey  NUMBER(12)  NOT NULL,
    ApplicationKey              NUMBER(12)  NOT NULL,
    ApplicationStatusKey        NUMBER(2)   NOT NULL,
    ChangedAt                   TIMESTAMP   NOT NULL
);

CREATE TABLE ApplicationStatus (
    ApplicationStatusKey   NUMBER(2)     NOT NULL,
    ApplicationStatusName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ConsentTextVersion (
    ConsentTextVersionKey  NUMBER(4)     NOT NULL,
    ConsentTypeKey         NUMBER(2)     NOT NULL,
    VersionLabel           VARCHAR2(10)  NOT NULL,
    ConsentText            CLOB          NOT NULL,
    ValidFrom              DATE          NOT NULL
);

CREATE TABLE ConsentType (
    ConsentTypeKey   NUMBER(2)     NOT NULL,
    ConsentTypeName  VARCHAR2(40)  NOT NULL
);

COMMENT ON TABLE CandidatePseudonym IS 'Kandydat znany tylko z pseudonimu nadanego przez platformę.';
COMMENT ON COLUMN CandidatePseudonym.CandidatePseudonymKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN CandidatePseudonym.SourcePlatformKey IS 'Platforma, która nadała pseudonim';
COMMENT ON COLUMN CandidatePseudonym.PseudonymValue IS 'Ciąg znaków od platformy';
COMMENT ON COLUMN CandidatePseudonym.FirstSeenAt IS 'Kiedy pierwszy raz się pojawił';

COMMENT ON TABLE Application IS 'Aplikacja kandydata na ogłoszenie, potwierdzona przez platformę.';
COMMENT ON COLUMN Application.ApplicationKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN Application.CandidatePseudonymKey IS 'Kandydat';
COMMENT ON COLUMN Application.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN Application.AppliedAt IS 'Kiedy aplikował';
COMMENT ON COLUMN Application.DataDeliveryKey IS 'W której dostawie przyszła informacja';

COMMENT ON TABLE Consent IS 'Decyzja kandydata o zgodzie – udzielenie albo wycofanie to nowy wiersz.';
COMMENT ON COLUMN Consent.ConsentKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN Consent.CandidatePseudonymKey IS 'Kandydat';
COMMENT ON COLUMN Consent.ConsentTextVersionKey IS 'Treść zgody, którą widział';
COMMENT ON COLUMN Consent.IsGranted IS 'T = zgoda udzielona, N = wycofana';
COMMENT ON COLUMN Consent.DecidedAt IS 'Kiedy';

COMMENT ON TABLE ApplicationStatusChange IS 'Zmiana stanu aplikacji – historia.';
COMMENT ON COLUMN ApplicationStatusChange.ApplicationStatusChangeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ApplicationStatusChange.ApplicationKey IS 'Aplikacja';
COMMENT ON COLUMN ApplicationStatusChange.ApplicationStatusKey IS 'Nowy stan';
COMMENT ON COLUMN ApplicationStatusChange.ChangedAt IS 'Kiedy';

COMMENT ON TABLE ApplicationStatus IS 'Stan aplikacji.';
COMMENT ON COLUMN ApplicationStatus.ApplicationStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ApplicationStatus.ApplicationStatusName IS 'Nazwa stanu';

COMMENT ON TABLE ConsentTextVersion IS 'Wersja treści zgody, którą kandydat zobaczył.';
COMMENT ON COLUMN ConsentTextVersion.ConsentTextVersionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ConsentTextVersion.ConsentTypeKey IS 'Na co jest zgoda';
COMMENT ON COLUMN ConsentTextVersion.VersionLabel IS 'Oznaczenie wersji, np. 1.2';
COMMENT ON COLUMN ConsentTextVersion.ConsentText IS 'Pełna treść zgody';
COMMENT ON COLUMN ConsentTextVersion.ValidFrom IS 'Od kiedy pokazywana';

COMMENT ON TABLE ConsentType IS 'Na co kandydat się zgadza.';
COMMENT ON COLUMN ConsentType.ConsentTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ConsentType.ConsentTypeName IS 'Nazwa zgody';

ALTER TABLE CandidatePseudonym ADD CONSTRAINT CandidatePseudonym_PK PRIMARY KEY (CandidatePseudonymKey);
ALTER TABLE CandidatePseudonym ADD CONSTRAINT CandidatePseudonym_UN UNIQUE (SourcePlatformKey, PseudonymValue);
ALTER TABLE Application ADD CONSTRAINT Application_PK PRIMARY KEY (ApplicationKey);
ALTER TABLE Application ADD CONSTRAINT Application_UN UNIQUE (CandidatePseudonymKey, JobPostingKey);
ALTER TABLE Consent ADD CONSTRAINT Consent_PK PRIMARY KEY (ConsentKey);
ALTER TABLE Consent ADD CONSTRAINT Consent_IsGranted_CK CHECK (IsGranted IN ('T', 'N'));
ALTER TABLE ApplicationStatusChange ADD CONSTRAINT ApplicationStatusChange_PK PRIMARY KEY (ApplicationStatusChangeKey);
ALTER TABLE ApplicationStatus ADD CONSTRAINT ApplicationStatus_PK PRIMARY KEY (ApplicationStatusKey);
ALTER TABLE ApplicationStatus ADD CONSTRAINT ApplicationStatus_ApplicationStatusName_UN UNIQUE (ApplicationStatusName);
ALTER TABLE ConsentTextVersion ADD CONSTRAINT ConsentTextVersion_PK PRIMARY KEY (ConsentTextVersionKey);
ALTER TABLE ConsentTextVersion ADD CONSTRAINT ConsentTextVersion_UN UNIQUE (ConsentTypeKey, VersionLabel);
ALTER TABLE ConsentType ADD CONSTRAINT ConsentType_PK PRIMARY KEY (ConsentTypeKey);
ALTER TABLE ConsentType ADD CONSTRAINT ConsentType_ConsentTypeName_UN UNIQUE (ConsentTypeName);

ALTER TABLE Application ADD CONSTRAINT Application_CandidatePseudonym_FK FOREIGN KEY (CandidatePseudonymKey) REFERENCES CandidatePseudonym (CandidatePseudonymKey);
ALTER TABLE Consent ADD CONSTRAINT Consent_CandidatePseudonym_FK FOREIGN KEY (CandidatePseudonymKey) REFERENCES CandidatePseudonym (CandidatePseudonymKey);
ALTER TABLE Consent ADD CONSTRAINT Consent_ConsentTextVersion_FK FOREIGN KEY (ConsentTextVersionKey) REFERENCES ConsentTextVersion (ConsentTextVersionKey);
ALTER TABLE ApplicationStatusChange ADD CONSTRAINT ApplicationStatusChange_Application_FK FOREIGN KEY (ApplicationKey) REFERENCES Application (ApplicationKey);
ALTER TABLE ApplicationStatusChange ADD CONSTRAINT ApplicationStatusChange_ApplicationStatus_FK FOREIGN KEY (ApplicationStatusKey) REFERENCES ApplicationStatus (ApplicationStatusKey);
ALTER TABLE ConsentTextVersion ADD CONSTRAINT ConsentTextVersion_ConsentType_FK FOREIGN KEY (ConsentTypeKey) REFERENCES ConsentType (ConsentTypeKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO ConsentType (ConsentTypeKey, ConsentTypeName) VALUES (1, 'Przypomnienia o wyniku rekrutacji');
INSERT INTO ConsentType (ConsentTypeKey, ConsentTypeName) VALUES (2, 'Zbieranie cech urządzenia');
INSERT INTO ApplicationStatus (ApplicationStatusKey, ApplicationStatusName) VALUES (1, 'Wysłana');
INSERT INTO ApplicationStatus (ApplicationStatusKey, ApplicationStatusName) VALUES (2, 'Wyświetlona przez firmę');
INSERT INTO ApplicationStatus (ApplicationStatusKey, ApplicationStatusName) VALUES (3, 'Odrzucona automatycznie');
INSERT INTO ApplicationStatus (ApplicationStatusKey, ApplicationStatusName) VALUES (4, 'Zaproszenie na rozmowę');
INSERT INTO ApplicationStatus (ApplicationStatusKey, ApplicationStatusName) VALUES (5, 'Oferta pracy');
INSERT INTO ApplicationStatus (ApplicationStatusKey, ApplicationStatusName) VALUES (6, 'Zatrudnienie');
INSERT INTO ApplicationStatus (ApplicationStatusKey, ApplicationStatusName) VALUES (7, 'Wycofana przez kandydata');
COMMIT;
