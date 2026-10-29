-- Organizm 15: Weryfikacja zgłoszenia
-- Niezależne sprawdzenia każdego zgłoszenia i ocena, czy liczy się do Trust Score.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE CheckType (
    CheckTypeKey   NUMBER(2)     NOT NULL,
    CheckTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE VerdictDecision (
    VerdictDecisionKey   NUMBER(2)     NOT NULL,
    VerdictDecisionName  VARCHAR2(20)  NOT NULL
);

CREATE TABLE ReportCheck (
    ReportCheckKey        NUMBER(12)     NOT NULL,
    RecruitmentReportKey  NUMBER(11)     NOT NULL,
    CheckTypeKey          NUMBER(2)      NOT NULL,
    CheckResultKey        NUMBER(2)      NOT NULL,
    CheckedAt             TIMESTAMP      NOT NULL,
    CheckDetails          VARCHAR2(400)
);

CREATE TABLE ReportVerdict (
    ReportVerdictKey      NUMBER(11)    NOT NULL,
    RecruitmentReportKey  NUMBER(11)    NOT NULL,
    VerdictDecisionKey    NUMBER(2)     NOT NULL,
    ReportWeight          NUMBER(3,2)   NOT NULL,
    RuleSetVersion        VARCHAR2(20)  NOT NULL,
    DecidedAt             TIMESTAMP     NOT NULL
);

CREATE TABLE CheckResult (
    CheckResultKey   NUMBER(2)     NOT NULL,
    CheckResultName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE ReportDevice (
    ReportDeviceKey       NUMBER(11)  NOT NULL,
    RecruitmentReportKey  NUMBER(11)  NOT NULL,
    DeviceFingerprintKey  NUMBER(10)  NOT NULL
);

CREATE TABLE DeviceFingerprint (
    DeviceFingerprintKey  NUMBER(10)    NOT NULL,
    FingerprintHash       VARCHAR2(64)  NOT NULL,
    FirstSeenAt           TIMESTAMP     NOT NULL,
    ExpiresAt             DATE          NOT NULL
);

COMMENT ON TABLE CheckType IS 'Rodzaj sprawdzenia.';
COMMENT ON COLUMN CheckType.CheckTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN CheckType.CheckTypeName IS 'Nazwa sprawdzenia';

COMMENT ON TABLE VerdictDecision IS 'Decyzja o zgłoszeniu.';
COMMENT ON COLUMN VerdictDecision.VerdictDecisionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN VerdictDecision.VerdictDecisionName IS 'Nazwa decyzji';

COMMENT ON TABLE ReportCheck IS 'Wynik jednego sprawdzenia jednego zgłoszenia.';
COMMENT ON COLUMN ReportCheck.ReportCheckKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ReportCheck.RecruitmentReportKey IS 'Zgłoszenie';
COMMENT ON COLUMN ReportCheck.CheckTypeKey IS 'Rodzaj sprawdzenia';
COMMENT ON COLUMN ReportCheck.CheckResultKey IS 'Wynik';
COMMENT ON COLUMN ReportCheck.CheckedAt IS 'Kiedy sprawdzono';
COMMENT ON COLUMN ReportCheck.CheckDetails IS 'Szczegóły, np. „aplikacja 34 dni temu”';

COMMENT ON TABLE ReportVerdict IS 'Ocena zgłoszenia – każda ponowna ocena to nowy wiersz.';
COMMENT ON COLUMN ReportVerdict.ReportVerdictKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ReportVerdict.RecruitmentReportKey IS 'Zgłoszenie';
COMMENT ON COLUMN ReportVerdict.VerdictDecisionKey IS 'Decyzja';
COMMENT ON COLUMN ReportVerdict.ReportWeight IS 'Waga od 0 do 1';
COMMENT ON COLUMN ReportVerdict.RuleSetVersion IS 'Wersja reguł oceny';
COMMENT ON COLUMN ReportVerdict.DecidedAt IS 'Kiedy oceniono';

COMMENT ON TABLE CheckResult IS 'Wynik sprawdzenia.';
COMMENT ON COLUMN CheckResult.CheckResultKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN CheckResult.CheckResultName IS 'Nazwa wyniku';

COMMENT ON TABLE ReportDevice IS 'Urządzenie, z którego wysłano zgłoszenie – tabela łącząca.';
COMMENT ON COLUMN ReportDevice.ReportDeviceKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ReportDevice.RecruitmentReportKey IS 'Zgłoszenie';
COMMENT ON COLUMN ReportDevice.DeviceFingerprintKey IS 'Urządzenie';

COMMENT ON TABLE DeviceFingerprint IS 'Urządzenie zapisane tylko jako skrót cech.';
COMMENT ON COLUMN DeviceFingerprint.DeviceFingerprintKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN DeviceFingerprint.FingerprintHash IS 'Skrót cech urządzenia (bez samych cech)';
COMMENT ON COLUMN DeviceFingerprint.FirstSeenAt IS 'Kiedy pierwszy raz';
COMMENT ON COLUMN DeviceFingerprint.ExpiresAt IS 'Kiedy usunąć – dane osobowe trzymamy krótko';

ALTER TABLE CheckType ADD CONSTRAINT CheckType_PK PRIMARY KEY (CheckTypeKey);
ALTER TABLE CheckType ADD CONSTRAINT CheckType_CheckTypeName_UN UNIQUE (CheckTypeName);
ALTER TABLE VerdictDecision ADD CONSTRAINT VerdictDecision_PK PRIMARY KEY (VerdictDecisionKey);
ALTER TABLE VerdictDecision ADD CONSTRAINT VerdictDecision_VerdictDecisionName_UN UNIQUE (VerdictDecisionName);
ALTER TABLE ReportCheck ADD CONSTRAINT ReportCheck_PK PRIMARY KEY (ReportCheckKey);
ALTER TABLE ReportVerdict ADD CONSTRAINT ReportVerdict_PK PRIMARY KEY (ReportVerdictKey);
ALTER TABLE ReportVerdict ADD CONSTRAINT ReportVerdict_CK1 CHECK (ReportWeight BETWEEN 0 AND 1);
ALTER TABLE CheckResult ADD CONSTRAINT CheckResult_PK PRIMARY KEY (CheckResultKey);
ALTER TABLE CheckResult ADD CONSTRAINT CheckResult_CheckResultName_UN UNIQUE (CheckResultName);
ALTER TABLE ReportDevice ADD CONSTRAINT ReportDevice_PK PRIMARY KEY (ReportDeviceKey);
ALTER TABLE ReportDevice ADD CONSTRAINT ReportDevice_RecruitmentReportKey_UN UNIQUE (RecruitmentReportKey);
ALTER TABLE DeviceFingerprint ADD CONSTRAINT DeviceFingerprint_PK PRIMARY KEY (DeviceFingerprintKey);
ALTER TABLE DeviceFingerprint ADD CONSTRAINT DeviceFingerprint_FingerprintHash_UN UNIQUE (FingerprintHash);

ALTER TABLE ReportCheck ADD CONSTRAINT ReportCheck_CheckType_FK FOREIGN KEY (CheckTypeKey) REFERENCES CheckType (CheckTypeKey);
ALTER TABLE ReportCheck ADD CONSTRAINT ReportCheck_CheckResult_FK FOREIGN KEY (CheckResultKey) REFERENCES CheckResult (CheckResultKey);
ALTER TABLE ReportVerdict ADD CONSTRAINT ReportVerdict_VerdictDecision_FK FOREIGN KEY (VerdictDecisionKey) REFERENCES VerdictDecision (VerdictDecisionKey);
ALTER TABLE ReportDevice ADD CONSTRAINT ReportDevice_DeviceFingerprint_FK FOREIGN KEY (DeviceFingerprintKey) REFERENCES DeviceFingerprint (DeviceFingerprintKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO CheckType (CheckTypeKey, CheckTypeName) VALUES (1, 'Człowiek czy bot (Cloudflare)');
INSERT INTO CheckType (CheckTypeKey, CheckTypeName) VALUES (2, 'Dowód aplikacji');
INSERT INTO CheckType (CheckTypeKey, CheckTypeName) VALUES (3, 'Odcisk urządzenia');
INSERT INTO CheckType (CheckTypeKey, CheckTypeName) VALUES (4, 'Fala zgłoszeń');
INSERT INTO VerdictDecision (VerdictDecisionKey, VerdictDecisionName) VALUES (1, 'Przyjęte');
INSERT INTO VerdictDecision (VerdictDecisionKey, VerdictDecisionName) VALUES (2, 'Do moderacji');
INSERT INTO VerdictDecision (VerdictDecisionKey, VerdictDecisionName) VALUES (3, 'Odrzucone');
INSERT INTO CheckResult (CheckResultKey, CheckResultName) VALUES (1, 'Pozytywny');
INSERT INTO CheckResult (CheckResultKey, CheckResultName) VALUES (2, 'Negatywny');
INSERT INTO CheckResult (CheckResultKey, CheckResultName) VALUES (3, 'Nie dało się sprawdzić');
INSERT INTO CheckResult (CheckResultKey, CheckResultName) VALUES (4, 'Za wcześnie');
COMMIT;
