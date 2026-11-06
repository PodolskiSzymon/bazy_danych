-- Organizm 16: Wykrywanie nadużyć
-- Wzorce wielu podejrzanych zgłoszeń naraz – podejrzenie, które potwierdza albo odrzuca człowiek.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG16_AlertType (
    AlertTypeKey   NUMBER(2)     NOT NULL,
    AlertTypeName  VARCHAR2(50)  NOT NULL
);

CREATE TABLE ORG16_AlertStatus (
    AlertStatusKey   NUMBER(2)     NOT NULL,
    AlertStatusName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE ORG16_AbuseAlert (
    AbuseAlertKey  NUMBER(7)  NOT NULL,
    EmployerKey    NUMBER(7)  NOT NULL,
    AlertTypeKey   NUMBER(2)  NOT NULL,
    WindowStart    TIMESTAMP  NOT NULL,
    WindowEnd      TIMESTAMP  NOT NULL,
    DetectedAt     TIMESTAMP  NOT NULL,
    ReportCount    NUMBER(6)  NOT NULL
);

CREATE TABLE ORG16_AlertStatusChange (
    AlertStatusChangeKey  NUMBER(7)      NOT NULL,
    AbuseAlertKey         NUMBER(7)      NOT NULL,
    AlertStatusKey        NUMBER(2)      NOT NULL,
    ChangedAt             TIMESTAMP      NOT NULL,
    ChangeComment         VARCHAR2(300),
    SystemUserKey         NUMBER(7),
    IsCurrent             NUMBER(1)      NOT NULL
);

CREATE TABLE ORG16_AlertReport (
    AlertReportKey        NUMBER(8)  NOT NULL,
    AbuseAlertKey         NUMBER(7)  NOT NULL,
    RecruitmentReportKey  NUMBER(9)  NOT NULL
);

COMMENT ON TABLE ORG16_AlertType IS 'Rodzaj podejrzanego wzorca.';
COMMENT ON COLUMN ORG16_AlertType.AlertTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG16_AlertType.AlertTypeName IS 'Nazwa wzorca';

COMMENT ON TABLE ORG16_AlertStatus IS 'Stan alertu.';
COMMENT ON COLUMN ORG16_AlertStatus.AlertStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG16_AlertStatus.AlertStatusName IS 'Nazwa stanu';

COMMENT ON TABLE ORG16_AbuseAlert IS 'Alert o podejrzanej fali zgłoszeń dotyczącej jednej firmy.';
COMMENT ON COLUMN ORG16_AbuseAlert.AbuseAlertKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG16_AbuseAlert.EmployerKey IS 'Firma';
COMMENT ON COLUMN ORG16_AbuseAlert.AlertTypeKey IS 'Rodzaj wzorca';
COMMENT ON COLUMN ORG16_AbuseAlert.WindowStart IS 'Początek okresu fali';
COMMENT ON COLUMN ORG16_AbuseAlert.WindowEnd IS 'Koniec okresu fali';
COMMENT ON COLUMN ORG16_AbuseAlert.DetectedAt IS 'Kiedy wykryto';
COMMENT ON COLUMN ORG16_AbuseAlert.ReportCount IS 'Ile zgłoszeń w fali';

COMMENT ON TABLE ORG16_AlertStatusChange IS 'Zmiana stanu alertu – historia z autorem; aktualny stan jest jeden.';
COMMENT ON COLUMN ORG16_AlertStatusChange.AlertStatusChangeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG16_AlertStatusChange.AbuseAlertKey IS 'Alert';
COMMENT ON COLUMN ORG16_AlertStatusChange.AlertStatusKey IS 'Nowy stan';
COMMENT ON COLUMN ORG16_AlertStatusChange.ChangedAt IS 'Kiedy';
COMMENT ON COLUMN ORG16_AlertStatusChange.ChangeComment IS 'Uzasadnienie';
COMMENT ON COLUMN ORG16_AlertStatusChange.SystemUserKey IS 'Kto zmienił (puste = program)';
COMMENT ON COLUMN ORG16_AlertStatusChange.IsCurrent IS '1 = stan aktualny';

COMMENT ON TABLE ORG16_AlertReport IS 'Zgłoszenie objęte alertem – tabela łącząca.';
COMMENT ON COLUMN ORG16_AlertReport.AlertReportKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG16_AlertReport.AbuseAlertKey IS 'Alert';
COMMENT ON COLUMN ORG16_AlertReport.RecruitmentReportKey IS 'Zgłoszenie';

ALTER TABLE ORG16_AlertType ADD CONSTRAINT ORG16_AlertType_PK PRIMARY KEY (AlertTypeKey);
ALTER TABLE ORG16_AlertType ADD CONSTRAINT ORG16_AlertType_AlertTypeName_UN UNIQUE (AlertTypeName);
ALTER TABLE ORG16_AlertStatus ADD CONSTRAINT ORG16_AlertStatus_PK PRIMARY KEY (AlertStatusKey);
ALTER TABLE ORG16_AlertStatus ADD CONSTRAINT ORG16_AlertStatus_AlertStatusName_UN UNIQUE (AlertStatusName);
ALTER TABLE ORG16_AbuseAlert ADD CONSTRAINT ORG16_AbuseAlert_PK PRIMARY KEY (AbuseAlertKey);
ALTER TABLE ORG16_AbuseAlert ADD CONSTRAINT ORG16_AbuseAlert_CK1 CHECK (WindowEnd >= WindowStart);
ALTER TABLE ORG16_AlertStatusChange ADD CONSTRAINT ORG16_AlertStatusChange_PK PRIMARY KEY (AlertStatusChangeKey);
ALTER TABLE ORG16_AlertStatusChange ADD CONSTRAINT ORG16_AlertStatusChange_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG16_AlertReport ADD CONSTRAINT ORG16_AlertReport_PK PRIMARY KEY (AlertReportKey);
ALTER TABLE ORG16_AlertReport ADD CONSTRAINT ORG16_AlertReport_UN UNIQUE (AbuseAlertKey, RecruitmentReportKey);

ALTER TABLE ORG16_AbuseAlert ADD CONSTRAINT ORG16_AbuseAlert_AlertType_FK FOREIGN KEY (AlertTypeKey) REFERENCES ORG16_AlertType (AlertTypeKey);
ALTER TABLE ORG16_AlertStatusChange ADD CONSTRAINT ORG16_AlertStatusChange_AbuseAlert_FK FOREIGN KEY (AbuseAlertKey) REFERENCES ORG16_AbuseAlert (AbuseAlertKey);
ALTER TABLE ORG16_AlertStatusChange ADD CONSTRAINT ORG16_AlertStatusChange_AlertStatus_FK FOREIGN KEY (AlertStatusKey) REFERENCES ORG16_AlertStatus (AlertStatusKey);
ALTER TABLE ORG16_AlertReport ADD CONSTRAINT ORG16_AlertReport_AbuseAlert_FK FOREIGN KEY (AbuseAlertKey) REFERENCES ORG16_AbuseAlert (AbuseAlertKey);

-- Unikalne tylko w części wierszy, np. jeden aktualny wiersz (unikalny indeks funkcyjny).
CREATE UNIQUE INDEX ORG16_AlertStatusChange_UX ON ORG16_AlertStatusChange (CASE WHEN IsCurrent = 1 THEN AbuseAlertKey END);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO ORG16_AlertType (AlertTypeKey, AlertTypeName) VALUES (1, 'Fala negatywnych zgłoszeń');
INSERT INTO ORG16_AlertType (AlertTypeKey, AlertTypeName) VALUES (2, 'Fala pozytywnych zgłoszeń od samej firmy');
INSERT INTO ORG16_AlertType (AlertTypeKey, AlertTypeName) VALUES (3, 'Jedno urządzenie, wiele pseudonimów');
INSERT INTO ORG16_AlertType (AlertTypeKey, AlertTypeName) VALUES (4, 'Zgłoszenia bez aplikacji');
INSERT INTO ORG16_AlertStatus (AlertStatusKey, AlertStatusName) VALUES (1, 'Nowy');
INSERT INTO ORG16_AlertStatus (AlertStatusKey, AlertStatusName) VALUES (2, 'W moderacji');
INSERT INTO ORG16_AlertStatus (AlertStatusKey, AlertStatusName) VALUES (3, 'Potwierdzone nadużycie');
INSERT INTO ORG16_AlertStatus (AlertStatusKey, AlertStatusName) VALUES (4, 'Fałszywy alarm');
COMMIT;
