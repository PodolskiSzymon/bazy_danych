-- Organizm 13: Kandydat, aplikacje i zgody
-- Osoba znana tylko z pseudonimu, jej aplikacje potwierdzone przez platformę i jej zgody.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG13_CandidatePseudonym (
    CandidatePseudonymKey  NUMBER(10)    NOT NULL,
    SourcePlatformKey      NUMBER(4)     NOT NULL,
    PseudonymValue         VARCHAR2(64)  NOT NULL,
    FirstSeenAt            TIMESTAMP     NOT NULL
);

CREATE TABLE ORG13_Application (
    ApplicationKey         NUMBER(12)  NOT NULL,
    CandidatePseudonymKey  NUMBER(10)  NOT NULL,
    JobPostingKey          NUMBER(10)  NOT NULL,
    AppliedAt              TIMESTAMP   NOT NULL,
    DataDeliveryKey        NUMBER(10)
);

CREATE TABLE ORG13_Consent (
    ConsentKey             NUMBER(11)  NOT NULL,
    CandidatePseudonymKey  NUMBER(10)  NOT NULL,
    ConsentTextVersionKey  NUMBER(4)   NOT NULL,
    IsGranted              CHAR(1)     NOT NULL,
    DecidedAt              TIMESTAMP   NOT NULL
);

CREATE TABLE ORG13_ApplicationStatusChange (
    ApplicationStatusChangeKey  NUMBER(12)  NOT NULL,
    ApplicationKey              NUMBER(12)  NOT NULL,
    ApplicationStatusKey        NUMBER(2)   NOT NULL,
    ChangedAt                   TIMESTAMP   NOT NULL
);

CREATE TABLE ORG13_ApplicationStatus (
    ApplicationStatusKey   NUMBER(2)     NOT NULL,
    ApplicationStatusName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG13_ConsentTextVersion (
    ConsentTextVersionKey  NUMBER(4)     NOT NULL,
    ConsentTypeKey         NUMBER(2)     NOT NULL,
    VersionLabel           VARCHAR2(10)  NOT NULL,
    ConsentText            CLOB          NOT NULL,
    ValidFrom              DATE          NOT NULL
);

CREATE TABLE ORG13_ConsentType (
    ConsentTypeKey   NUMBER(2)     NOT NULL,
    ConsentTypeName  VARCHAR2(40)  NOT NULL
);

COMMENT ON TABLE ORG13_CandidatePseudonym IS 'Kandydat znany tylko z pseudonimu nadanego przez platformę.';
COMMENT ON COLUMN ORG13_CandidatePseudonym.CandidatePseudonymKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG13_CandidatePseudonym.SourcePlatformKey IS 'Platforma, która nadała pseudonim';
COMMENT ON COLUMN ORG13_CandidatePseudonym.PseudonymValue IS 'Ciąg znaków od platformy';
COMMENT ON COLUMN ORG13_CandidatePseudonym.FirstSeenAt IS 'Kiedy pierwszy raz się pojawił';

COMMENT ON TABLE ORG13_Application IS 'Aplikacja kandydata na ogłoszenie, potwierdzona przez platformę.';
COMMENT ON COLUMN ORG13_Application.ApplicationKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG13_Application.CandidatePseudonymKey IS 'Kandydat';
COMMENT ON COLUMN ORG13_Application.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN ORG13_Application.AppliedAt IS 'Kiedy aplikował';
COMMENT ON COLUMN ORG13_Application.DataDeliveryKey IS 'W której dostawie przyszła informacja';

COMMENT ON TABLE ORG13_Consent IS 'Decyzja kandydata o zgodzie – udzielenie albo wycofanie to nowy wiersz.';
COMMENT ON COLUMN ORG13_Consent.ConsentKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG13_Consent.CandidatePseudonymKey IS 'Kandydat';
COMMENT ON COLUMN ORG13_Consent.ConsentTextVersionKey IS 'Treść zgody, którą widział';
COMMENT ON COLUMN ORG13_Consent.IsGranted IS 'T = zgoda udzielona, N = wycofana';
COMMENT ON COLUMN ORG13_Consent.DecidedAt IS 'Kiedy';

COMMENT ON TABLE ORG13_ApplicationStatusChange IS 'Zmiana stanu aplikacji – historia.';
COMMENT ON COLUMN ORG13_ApplicationStatusChange.ApplicationStatusChangeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG13_ApplicationStatusChange.ApplicationKey IS 'Aplikacja';
COMMENT ON COLUMN ORG13_ApplicationStatusChange.ApplicationStatusKey IS 'Nowy stan';
COMMENT ON COLUMN ORG13_ApplicationStatusChange.ChangedAt IS 'Kiedy';

COMMENT ON TABLE ORG13_ApplicationStatus IS 'Stan aplikacji.';
COMMENT ON COLUMN ORG13_ApplicationStatus.ApplicationStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG13_ApplicationStatus.ApplicationStatusName IS 'Nazwa stanu';

COMMENT ON TABLE ORG13_ConsentTextVersion IS 'Wersja treści zgody, którą kandydat zobaczył.';
COMMENT ON COLUMN ORG13_ConsentTextVersion.ConsentTextVersionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG13_ConsentTextVersion.ConsentTypeKey IS 'Na co jest zgoda';
COMMENT ON COLUMN ORG13_ConsentTextVersion.VersionLabel IS 'Oznaczenie wersji, np. 1.2';
COMMENT ON COLUMN ORG13_ConsentTextVersion.ConsentText IS 'Pełna treść zgody';
COMMENT ON COLUMN ORG13_ConsentTextVersion.ValidFrom IS 'Od kiedy pokazywana';

COMMENT ON TABLE ORG13_ConsentType IS 'Na co kandydat się zgadza.';
COMMENT ON COLUMN ORG13_ConsentType.ConsentTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG13_ConsentType.ConsentTypeName IS 'Nazwa zgody';

ALTER TABLE ORG13_CandidatePseudonym ADD CONSTRAINT ORG13_CandidatePseudonym_PK PRIMARY KEY (CandidatePseudonymKey);
ALTER TABLE ORG13_CandidatePseudonym ADD CONSTRAINT ORG13_CandidatePseudonym_UN UNIQUE (SourcePlatformKey, PseudonymValue);
ALTER TABLE ORG13_Application ADD CONSTRAINT ORG13_Application_PK PRIMARY KEY (ApplicationKey);
ALTER TABLE ORG13_Application ADD CONSTRAINT ORG13_Application_UN UNIQUE (CandidatePseudonymKey, JobPostingKey);
ALTER TABLE ORG13_Consent ADD CONSTRAINT ORG13_Consent_PK PRIMARY KEY (ConsentKey);
ALTER TABLE ORG13_Consent ADD CONSTRAINT ORG13_Consent_IsGranted_CK CHECK (IsGranted IN ('T', 'N'));
ALTER TABLE ORG13_ApplicationStatusChange ADD CONSTRAINT ORG13_ApplicationStatusChange_PK PRIMARY KEY (ApplicationStatusChangeKey);
ALTER TABLE ORG13_ApplicationStatus ADD CONSTRAINT ORG13_ApplicationStatus_PK PRIMARY KEY (ApplicationStatusKey);
ALTER TABLE ORG13_ApplicationStatus ADD CONSTRAINT ORG13_ApplicationStatus_ApplicationStatusName_UN UNIQUE (ApplicationStatusName);
ALTER TABLE ORG13_ConsentTextVersion ADD CONSTRAINT ORG13_ConsentTextVersion_PK PRIMARY KEY (ConsentTextVersionKey);
ALTER TABLE ORG13_ConsentTextVersion ADD CONSTRAINT ORG13_ConsentTextVersion_UN UNIQUE (ConsentTypeKey, VersionLabel);
ALTER TABLE ORG13_ConsentType ADD CONSTRAINT ORG13_ConsentType_PK PRIMARY KEY (ConsentTypeKey);
ALTER TABLE ORG13_ConsentType ADD CONSTRAINT ORG13_ConsentType_ConsentTypeName_UN UNIQUE (ConsentTypeName);

ALTER TABLE ORG13_Application ADD CONSTRAINT ORG13_Application_CandidatePseudonym_FK FOREIGN KEY (CandidatePseudonymKey) REFERENCES ORG13_CandidatePseudonym (CandidatePseudonymKey);
ALTER TABLE ORG13_Consent ADD CONSTRAINT ORG13_Consent_CandidatePseudonym_FK FOREIGN KEY (CandidatePseudonymKey) REFERENCES ORG13_CandidatePseudonym (CandidatePseudonymKey);
ALTER TABLE ORG13_Consent ADD CONSTRAINT ORG13_Consent_ConsentTextVersion_FK FOREIGN KEY (ConsentTextVersionKey) REFERENCES ORG13_ConsentTextVersion (ConsentTextVersionKey);
ALTER TABLE ORG13_ApplicationStatusChange ADD CONSTRAINT ORG13_ApplicationStatusChange_Application_FK FOREIGN KEY (ApplicationKey) REFERENCES ORG13_Application (ApplicationKey);
ALTER TABLE ORG13_ApplicationStatusChange ADD CONSTRAINT ORG13_ApplicationStatusChange_ApplicationStatus_FK FOREIGN KEY (ApplicationStatusKey) REFERENCES ORG13_ApplicationStatus (ApplicationStatusKey);
ALTER TABLE ORG13_ConsentTextVersion ADD CONSTRAINT ORG13_ConsentTextVersion_ConsentType_FK FOREIGN KEY (ConsentTypeKey) REFERENCES ORG13_ConsentType (ConsentTypeKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO ORG13_ConsentType (ConsentTypeKey, ConsentTypeName) VALUES (1, 'Przypomnienia o wyniku rekrutacji');
INSERT INTO ORG13_ConsentType (ConsentTypeKey, ConsentTypeName) VALUES (2, 'Zbieranie cech urządzenia');
INSERT INTO ORG13_ApplicationStatus (ApplicationStatusKey, ApplicationStatusName) VALUES (1, 'Wysłana');
INSERT INTO ORG13_ApplicationStatus (ApplicationStatusKey, ApplicationStatusName) VALUES (2, 'Wyświetlona przez firmę');
INSERT INTO ORG13_ApplicationStatus (ApplicationStatusKey, ApplicationStatusName) VALUES (3, 'Odrzucona automatycznie');
INSERT INTO ORG13_ApplicationStatus (ApplicationStatusKey, ApplicationStatusName) VALUES (4, 'Zaproszenie na rozmowę');
INSERT INTO ORG13_ApplicationStatus (ApplicationStatusKey, ApplicationStatusName) VALUES (5, 'Oferta pracy');
INSERT INTO ORG13_ApplicationStatus (ApplicationStatusKey, ApplicationStatusName) VALUES (6, 'Zatrudnienie');
INSERT INTO ORG13_ApplicationStatus (ApplicationStatusKey, ApplicationStatusName) VALUES (7, 'Wycofana przez kandydata');
COMMIT;
