-- Organizm 15: Weryfikacja zgłoszenia
-- Niezależne sprawdzenia każdego zgłoszenia i ocena, czy liczy się do Trust Score.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG15_CheckType (
    CheckTypeKey   NUMBER(2)     NOT NULL,
    CheckTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG15_VerdictDecision (
    VerdictDecisionKey   NUMBER(2)     NOT NULL,
    VerdictDecisionName  VARCHAR2(20)  NOT NULL
);

CREATE TABLE ORG15_ReportCheck (
    ReportCheckKey        NUMBER(12)     NOT NULL,
    RecruitmentReportKey  NUMBER(11)     NOT NULL,
    CheckTypeKey          NUMBER(2)      NOT NULL,
    CheckResultKey        NUMBER(2)      NOT NULL,
    CheckedAt             TIMESTAMP      NOT NULL,
    CheckDetails          VARCHAR2(400)
);

CREATE TABLE ORG15_ReportVerdict (
    ReportVerdictKey      NUMBER(11)    NOT NULL,
    RecruitmentReportKey  NUMBER(11)    NOT NULL,
    VerdictDecisionKey    NUMBER(2)     NOT NULL,
    ReportWeight          NUMBER(3,2)   NOT NULL,
    RuleSetVersion        VARCHAR2(20)  NOT NULL,
    DecidedAt             TIMESTAMP     NOT NULL
);

CREATE TABLE ORG15_CheckResult (
    CheckResultKey   NUMBER(2)     NOT NULL,
    CheckResultName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE ORG15_ReportDevice (
    ReportDeviceKey       NUMBER(11)  NOT NULL,
    RecruitmentReportKey  NUMBER(11)  NOT NULL,
    DeviceFingerprintKey  NUMBER(10)  NOT NULL
);

CREATE TABLE ORG15_DeviceFingerprint (
    DeviceFingerprintKey  NUMBER(10)    NOT NULL,
    FingerprintHash       VARCHAR2(64)  NOT NULL,
    FirstSeenAt           TIMESTAMP     NOT NULL,
    ExpiresAt             DATE          NOT NULL
);

COMMENT ON TABLE ORG15_CheckType IS 'Rodzaj sprawdzenia.';
COMMENT ON COLUMN ORG15_CheckType.CheckTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG15_CheckType.CheckTypeName IS 'Nazwa sprawdzenia';

COMMENT ON TABLE ORG15_VerdictDecision IS 'Decyzja o zgłoszeniu.';
COMMENT ON COLUMN ORG15_VerdictDecision.VerdictDecisionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG15_VerdictDecision.VerdictDecisionName IS 'Nazwa decyzji';

COMMENT ON TABLE ORG15_ReportCheck IS 'Wynik jednego sprawdzenia jednego zgłoszenia.';
COMMENT ON COLUMN ORG15_ReportCheck.ReportCheckKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG15_ReportCheck.RecruitmentReportKey IS 'Zgłoszenie';
COMMENT ON COLUMN ORG15_ReportCheck.CheckTypeKey IS 'Rodzaj sprawdzenia';
COMMENT ON COLUMN ORG15_ReportCheck.CheckResultKey IS 'Wynik';
COMMENT ON COLUMN ORG15_ReportCheck.CheckedAt IS 'Kiedy sprawdzono';
COMMENT ON COLUMN ORG15_ReportCheck.CheckDetails IS 'Szczegóły, np. „aplikacja 34 dni temu”';

COMMENT ON TABLE ORG15_ReportVerdict IS 'Ocena zgłoszenia – każda ponowna ocena to nowy wiersz.';
COMMENT ON COLUMN ORG15_ReportVerdict.ReportVerdictKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG15_ReportVerdict.RecruitmentReportKey IS 'Zgłoszenie';
COMMENT ON COLUMN ORG15_ReportVerdict.VerdictDecisionKey IS 'Decyzja';
COMMENT ON COLUMN ORG15_ReportVerdict.ReportWeight IS 'Waga od 0 do 1';
COMMENT ON COLUMN ORG15_ReportVerdict.RuleSetVersion IS 'Wersja reguł oceny';
COMMENT ON COLUMN ORG15_ReportVerdict.DecidedAt IS 'Kiedy oceniono';

COMMENT ON TABLE ORG15_CheckResult IS 'Wynik sprawdzenia.';
COMMENT ON COLUMN ORG15_CheckResult.CheckResultKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG15_CheckResult.CheckResultName IS 'Nazwa wyniku';

COMMENT ON TABLE ORG15_ReportDevice IS 'Urządzenie, z którego wysłano zgłoszenie – tabela łącząca.';
COMMENT ON COLUMN ORG15_ReportDevice.ReportDeviceKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG15_ReportDevice.RecruitmentReportKey IS 'Zgłoszenie';
COMMENT ON COLUMN ORG15_ReportDevice.DeviceFingerprintKey IS 'Urządzenie';

COMMENT ON TABLE ORG15_DeviceFingerprint IS 'Urządzenie zapisane tylko jako skrót cech.';
COMMENT ON COLUMN ORG15_DeviceFingerprint.DeviceFingerprintKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG15_DeviceFingerprint.FingerprintHash IS 'Skrót cech urządzenia (bez samych cech)';
COMMENT ON COLUMN ORG15_DeviceFingerprint.FirstSeenAt IS 'Kiedy pierwszy raz';
COMMENT ON COLUMN ORG15_DeviceFingerprint.ExpiresAt IS 'Kiedy usunąć – dane osobowe trzymamy krótko';

ALTER TABLE ORG15_CheckType ADD CONSTRAINT ORG15_CheckType_PK PRIMARY KEY (CheckTypeKey);
ALTER TABLE ORG15_CheckType ADD CONSTRAINT ORG15_CheckType_CheckTypeName_UN UNIQUE (CheckTypeName);
ALTER TABLE ORG15_VerdictDecision ADD CONSTRAINT ORG15_VerdictDecision_PK PRIMARY KEY (VerdictDecisionKey);
ALTER TABLE ORG15_VerdictDecision ADD CONSTRAINT ORG15_VerdictDecision_VerdictDecisionName_UN UNIQUE (VerdictDecisionName);
ALTER TABLE ORG15_ReportCheck ADD CONSTRAINT ORG15_ReportCheck_PK PRIMARY KEY (ReportCheckKey);
ALTER TABLE ORG15_ReportVerdict ADD CONSTRAINT ORG15_ReportVerdict_PK PRIMARY KEY (ReportVerdictKey);
ALTER TABLE ORG15_ReportVerdict ADD CONSTRAINT ORG15_ReportVerdict_CK1 CHECK (ReportWeight BETWEEN 0 AND 1);
ALTER TABLE ORG15_CheckResult ADD CONSTRAINT ORG15_CheckResult_PK PRIMARY KEY (CheckResultKey);
ALTER TABLE ORG15_CheckResult ADD CONSTRAINT ORG15_CheckResult_CheckResultName_UN UNIQUE (CheckResultName);
ALTER TABLE ORG15_ReportDevice ADD CONSTRAINT ORG15_ReportDevice_PK PRIMARY KEY (ReportDeviceKey);
ALTER TABLE ORG15_ReportDevice ADD CONSTRAINT ORG15_ReportDevice_RecruitmentReportKey_UN UNIQUE (RecruitmentReportKey);
ALTER TABLE ORG15_DeviceFingerprint ADD CONSTRAINT ORG15_DeviceFingerprint_PK PRIMARY KEY (DeviceFingerprintKey);
ALTER TABLE ORG15_DeviceFingerprint ADD CONSTRAINT ORG15_DeviceFingerprint_FingerprintHash_UN UNIQUE (FingerprintHash);

ALTER TABLE ORG15_ReportCheck ADD CONSTRAINT ORG15_ReportCheck_CheckType_FK FOREIGN KEY (CheckTypeKey) REFERENCES ORG15_CheckType (CheckTypeKey);
ALTER TABLE ORG15_ReportCheck ADD CONSTRAINT ORG15_ReportCheck_CheckResult_FK FOREIGN KEY (CheckResultKey) REFERENCES ORG15_CheckResult (CheckResultKey);
ALTER TABLE ORG15_ReportVerdict ADD CONSTRAINT ORG15_ReportVerdict_VerdictDecision_FK FOREIGN KEY (VerdictDecisionKey) REFERENCES ORG15_VerdictDecision (VerdictDecisionKey);
ALTER TABLE ORG15_ReportDevice ADD CONSTRAINT ORG15_ReportDevice_DeviceFingerprint_FK FOREIGN KEY (DeviceFingerprintKey) REFERENCES ORG15_DeviceFingerprint (DeviceFingerprintKey);
