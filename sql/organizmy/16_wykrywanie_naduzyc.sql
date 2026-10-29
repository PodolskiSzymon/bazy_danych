-- Organizm 16: Wykrywanie nadużyć
-- Wzorce wielu podejrzanych zgłoszeń naraz – podejrzenie, które potwierdza albo odrzuca człowiek.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE AlertType (
    AlertTypeKey   NUMBER(2)     NOT NULL,
    AlertTypeName  VARCHAR2(50)  NOT NULL
);

CREATE TABLE AlertStatus (
    AlertStatusKey   NUMBER(2)     NOT NULL,
    AlertStatusName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE AbuseAlert (
    AbuseAlertKey   NUMBER(9)  NOT NULL,
    EmployerKey     NUMBER(8)  NOT NULL,
    AlertTypeKey    NUMBER(2)  NOT NULL,
    AlertStatusKey  NUMBER(2)  NOT NULL,
    WindowStart     TIMESTAMP  NOT NULL,
    WindowEnd       TIMESTAMP  NOT NULL,
    DetectedAt      TIMESTAMP  NOT NULL,
    ReportCount     NUMBER(6)  NOT NULL
);

CREATE TABLE AlertReport (
    AlertReportKey        NUMBER(11)  NOT NULL,
    AbuseAlertKey         NUMBER(9)   NOT NULL,
    RecruitmentReportKey  NUMBER(11)  NOT NULL
);

COMMENT ON TABLE AlertType IS 'Rodzaj podejrzanego wzorca.';
COMMENT ON COLUMN AlertType.AlertTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN AlertType.AlertTypeName IS 'Nazwa wzorca';

COMMENT ON TABLE AlertStatus IS 'Stan alertu.';
COMMENT ON COLUMN AlertStatus.AlertStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN AlertStatus.AlertStatusName IS 'Nazwa stanu';

COMMENT ON TABLE AbuseAlert IS 'Alert o podejrzanej fali zgłoszeń dotyczącej jednej firmy.';
COMMENT ON COLUMN AbuseAlert.AbuseAlertKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN AbuseAlert.EmployerKey IS 'Firma';
COMMENT ON COLUMN AbuseAlert.AlertTypeKey IS 'Rodzaj wzorca';
COMMENT ON COLUMN AbuseAlert.AlertStatusKey IS 'Stan';
COMMENT ON COLUMN AbuseAlert.WindowStart IS 'Początek okresu fali';
COMMENT ON COLUMN AbuseAlert.WindowEnd IS 'Koniec okresu fali';
COMMENT ON COLUMN AbuseAlert.DetectedAt IS 'Kiedy wykryto';
COMMENT ON COLUMN AbuseAlert.ReportCount IS 'Ile zgłoszeń w fali';

COMMENT ON TABLE AlertReport IS 'Zgłoszenie objęte alertem – tabela łącząca.';
COMMENT ON COLUMN AlertReport.AlertReportKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN AlertReport.AbuseAlertKey IS 'Alert';
COMMENT ON COLUMN AlertReport.RecruitmentReportKey IS 'Zgłoszenie';

ALTER TABLE AlertType ADD CONSTRAINT AlertType_PK PRIMARY KEY (AlertTypeKey);
ALTER TABLE AlertType ADD CONSTRAINT AlertType_AlertTypeName_UN UNIQUE (AlertTypeName);
ALTER TABLE AlertStatus ADD CONSTRAINT AlertStatus_PK PRIMARY KEY (AlertStatusKey);
ALTER TABLE AlertStatus ADD CONSTRAINT AlertStatus_AlertStatusName_UN UNIQUE (AlertStatusName);
ALTER TABLE AbuseAlert ADD CONSTRAINT AbuseAlert_PK PRIMARY KEY (AbuseAlertKey);
ALTER TABLE AbuseAlert ADD CONSTRAINT AbuseAlert_CK1 CHECK (WindowEnd >= WindowStart);
ALTER TABLE AlertReport ADD CONSTRAINT AlertReport_PK PRIMARY KEY (AlertReportKey);
ALTER TABLE AlertReport ADD CONSTRAINT AlertReport_UN UNIQUE (AbuseAlertKey, RecruitmentReportKey);

ALTER TABLE AbuseAlert ADD CONSTRAINT AbuseAlert_AlertType_FK FOREIGN KEY (AlertTypeKey) REFERENCES AlertType (AlertTypeKey);
ALTER TABLE AbuseAlert ADD CONSTRAINT AbuseAlert_AlertStatus_FK FOREIGN KEY (AlertStatusKey) REFERENCES AlertStatus (AlertStatusKey);
ALTER TABLE AlertReport ADD CONSTRAINT AlertReport_AbuseAlert_FK FOREIGN KEY (AbuseAlertKey) REFERENCES AbuseAlert (AbuseAlertKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO AlertType (AlertTypeKey, AlertTypeName) VALUES (1, 'Fala negatywnych zgłoszeń');
INSERT INTO AlertType (AlertTypeKey, AlertTypeName) VALUES (2, 'Fala pozytywnych zgłoszeń od samej firmy');
INSERT INTO AlertType (AlertTypeKey, AlertTypeName) VALUES (3, 'Jedno urządzenie, wiele pseudonimów');
INSERT INTO AlertType (AlertTypeKey, AlertTypeName) VALUES (4, 'Zgłoszenia bez aplikacji');
INSERT INTO AlertStatus (AlertStatusKey, AlertStatusName) VALUES (1, 'Nowy');
INSERT INTO AlertStatus (AlertStatusKey, AlertStatusName) VALUES (2, 'W moderacji');
INSERT INTO AlertStatus (AlertStatusKey, AlertStatusName) VALUES (3, 'Potwierdzone nadużycie');
INSERT INTO AlertStatus (AlertStatusKey, AlertStatusName) VALUES (4, 'Fałszywy alarm');
COMMIT;
