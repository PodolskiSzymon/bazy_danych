-- Organizm 18: Trust Score i publikacja
-- Wynik firmy policzony konkretną metodą, z pewnością i powodami – oraz to, co wolno pokazać kandydatowi.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ScoringMethodType (
    ScoringMethodTypeKey   NUMBER(2)     NOT NULL,
    ScoringMethodTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ScoringMethod (
    ScoringMethodKey      NUMBER(4)     NOT NULL,
    ScoringMethodTypeKey  NUMBER(2)     NOT NULL,
    MethodVersion         VARCHAR2(20)  NOT NULL,
    ValidFrom             DATE          NOT NULL,
    ValidTo               DATE
);

CREATE TABLE ScoringWeight (
    ScoringWeightKey  NUMBER(6)    NOT NULL,
    ScoringMethodKey  NUMBER(4)    NOT NULL,
    SignalTypeKey     NUMBER(3)    NOT NULL,
    WeightValue       NUMBER(5,3)  NOT NULL
);

CREATE TABLE TrustScore (
    TrustScoreKey      NUMBER(11)   NOT NULL,
    SignalSnapshotKey  NUMBER(10)   NOT NULL,
    ScoringMethodKey   NUMBER(4)    NOT NULL,
    ScoreValue         NUMBER(3)    NOT NULL,
    ScoreConfidence    NUMBER(3,2)  NOT NULL,
    CalculatedAt       TIMESTAMP    NOT NULL
);

CREATE TABLE ScoreReason (
    ScoreReasonKey  NUMBER(12)     NOT NULL,
    TrustScoreKey   NUMBER(11)     NOT NULL,
    SignalTypeKey   NUMBER(3)      NOT NULL,
    ReasonRank      NUMBER(1)      NOT NULL,
    ReasonText      VARCHAR2(300)  NOT NULL
);

CREATE TABLE PublishedScore (
    PublishedScoreKey     NUMBER(10)  NOT NULL,
    TrustScoreKey         NUMBER(11)  NOT NULL,
    PublicationStatusKey  NUMBER(2)   NOT NULL,
    PublishedFrom         TIMESTAMP   NOT NULL,
    PublishedTo           TIMESTAMP
);

CREATE TABLE PublicationStatus (
    PublicationStatusKey   NUMBER(2)     NOT NULL,
    PublicationStatusName  VARCHAR2(40)  NOT NULL
);

COMMENT ON TABLE ScoringMethodType IS 'Rodzaj metody liczenia wyniku.';
COMMENT ON COLUMN ScoringMethodType.ScoringMethodTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ScoringMethodType.ScoringMethodTypeName IS 'Nazwa rodzaju metody';

COMMENT ON TABLE ScoringMethod IS 'Metoda liczenia wyniku w konkretnej wersji.';
COMMENT ON COLUMN ScoringMethod.ScoringMethodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ScoringMethod.ScoringMethodTypeKey IS 'Rodzaj metody';
COMMENT ON COLUMN ScoringMethod.MethodVersion IS 'Wersja';
COMMENT ON COLUMN ScoringMethod.ValidFrom IS 'Od kiedy używana';
COMMENT ON COLUMN ScoringMethod.ValidTo IS 'Do kiedy (puste = obecna)';

COMMENT ON TABLE ScoringWeight IS 'Waga sygnału w danej metodzie – tabela łącząca z wartością.';
COMMENT ON COLUMN ScoringWeight.ScoringWeightKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ScoringWeight.ScoringMethodKey IS 'Metoda';
COMMENT ON COLUMN ScoringWeight.SignalTypeKey IS 'Sygnał';
COMMENT ON COLUMN ScoringWeight.WeightValue IS 'Waga';

COMMENT ON TABLE TrustScore IS 'Wynik roboczy – każde przeliczenie to nowy wiersz.';
COMMENT ON COLUMN TrustScore.TrustScoreKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN TrustScore.SignalSnapshotKey IS 'Na jakich danych liczono';
COMMENT ON COLUMN TrustScore.ScoringMethodKey IS 'Jaką metodą';
COMMENT ON COLUMN TrustScore.ScoreValue IS 'Wynik od 0 do 100';
COMMENT ON COLUMN TrustScore.ScoreConfidence IS 'Pewność od 0 do 1';
COMMENT ON COLUMN TrustScore.CalculatedAt IS 'Kiedy policzono';

COMMENT ON TABLE ScoreReason IS 'Powód wyniku pokazywany kandydatowi i firmie.';
COMMENT ON COLUMN ScoreReason.ScoreReasonKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ScoreReason.TrustScoreKey IS 'Wynik';
COMMENT ON COLUMN ScoreReason.SignalTypeKey IS 'Którego sygnału dotyczy';
COMMENT ON COLUMN ScoreReason.ReasonRank IS 'Kolejność ważności';
COMMENT ON COLUMN ScoreReason.ReasonText IS 'Tekst, np. „to samo ogłoszenie 7 razy w 9 miesięcy”';

COMMENT ON TABLE PublishedScore IS 'Wynik pokazany publicznie – osobno od wyniku roboczego.';
COMMENT ON COLUMN PublishedScore.PublishedScoreKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN PublishedScore.TrustScoreKey IS 'Który wynik pokazujemy';
COMMENT ON COLUMN PublishedScore.PublicationStatusKey IS 'Stan publikacji';
COMMENT ON COLUMN PublishedScore.PublishedFrom IS 'Od kiedy';
COMMENT ON COLUMN PublishedScore.PublishedTo IS 'Do kiedy (puste = widoczny teraz)';

COMMENT ON TABLE PublicationStatus IS 'Stan publikacji wyniku.';
COMMENT ON COLUMN PublicationStatus.PublicationStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN PublicationStatus.PublicationStatusName IS 'Nazwa stanu publikacji';

ALTER TABLE ScoringMethodType ADD CONSTRAINT ScoringMethodType_PK PRIMARY KEY (ScoringMethodTypeKey);
ALTER TABLE ScoringMethodType ADD CONSTRAINT ScoringMethodType_ScoringMethodTypeName_UN UNIQUE (ScoringMethodTypeName);
ALTER TABLE ScoringMethod ADD CONSTRAINT ScoringMethod_PK PRIMARY KEY (ScoringMethodKey);
ALTER TABLE ScoringMethod ADD CONSTRAINT ScoringMethod_UN UNIQUE (ScoringMethodTypeKey, MethodVersion);
ALTER TABLE ScoringWeight ADD CONSTRAINT ScoringWeight_PK PRIMARY KEY (ScoringWeightKey);
ALTER TABLE ScoringWeight ADD CONSTRAINT ScoringWeight_UN UNIQUE (ScoringMethodKey, SignalTypeKey);
ALTER TABLE TrustScore ADD CONSTRAINT TrustScore_PK PRIMARY KEY (TrustScoreKey);
ALTER TABLE TrustScore ADD CONSTRAINT TrustScore_CK1 CHECK (ScoreValue BETWEEN 0 AND 100);
ALTER TABLE TrustScore ADD CONSTRAINT TrustScore_CK2 CHECK (ScoreConfidence BETWEEN 0 AND 1);
ALTER TABLE ScoreReason ADD CONSTRAINT ScoreReason_PK PRIMARY KEY (ScoreReasonKey);
ALTER TABLE ScoreReason ADD CONSTRAINT ScoreReason_UN UNIQUE (TrustScoreKey, ReasonRank);
ALTER TABLE PublishedScore ADD CONSTRAINT PublishedScore_PK PRIMARY KEY (PublishedScoreKey);
ALTER TABLE PublishedScore ADD CONSTRAINT PublishedScore_CK1 CHECK (PublishedTo IS NULL OR PublishedTo >= PublishedFrom);
ALTER TABLE PublicationStatus ADD CONSTRAINT PublicationStatus_PK PRIMARY KEY (PublicationStatusKey);
ALTER TABLE PublicationStatus ADD CONSTRAINT PublicationStatus_PublicationStatusName_UN UNIQUE (PublicationStatusName);

ALTER TABLE ScoringMethod ADD CONSTRAINT ScoringMethod_ScoringMethodType_FK FOREIGN KEY (ScoringMethodTypeKey) REFERENCES ScoringMethodType (ScoringMethodTypeKey);
ALTER TABLE ScoringWeight ADD CONSTRAINT ScoringWeight_ScoringMethod_FK FOREIGN KEY (ScoringMethodKey) REFERENCES ScoringMethod (ScoringMethodKey);
ALTER TABLE TrustScore ADD CONSTRAINT TrustScore_ScoringMethod_FK FOREIGN KEY (ScoringMethodKey) REFERENCES ScoringMethod (ScoringMethodKey);
ALTER TABLE ScoreReason ADD CONSTRAINT ScoreReason_TrustScore_FK FOREIGN KEY (TrustScoreKey) REFERENCES TrustScore (TrustScoreKey);
ALTER TABLE PublishedScore ADD CONSTRAINT PublishedScore_TrustScore_FK FOREIGN KEY (TrustScoreKey) REFERENCES TrustScore (TrustScoreKey);
ALTER TABLE PublishedScore ADD CONSTRAINT PublishedScore_PublicationStatus_FK FOREIGN KEY (PublicationStatusKey) REFERENCES PublicationStatus (PublicationStatusKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO ScoringMethodType (ScoringMethodTypeKey, ScoringMethodTypeName) VALUES (1, 'Wagi ustalone przez zespół');
INSERT INTO ScoringMethodType (ScoringMethodTypeKey, ScoringMethodTypeName) VALUES (2, 'Wytrenowany model');
INSERT INTO ScoringMethod (ScoringMethodKey, ScoringMethodTypeKey, MethodVersion, ValidFrom, ValidTo) VALUES (1, 1, '1.0', DATE '2026-12-01', NULL);
INSERT INTO PublicationStatus (PublicationStatusKey, PublicationStatusName) VALUES (1, 'Opublikowany');
INSERT INTO PublicationStatus (PublicationStatusKey, PublicationStatusName) VALUES (2, 'Za mało danych');
INSERT INTO PublicationStatus (PublicationStatusKey, PublicationStatusName) VALUES (3, 'Wstrzymany do decyzji moderatora');
INSERT INTO PublicationStatus (PublicationStatusKey, PublicationStatusName) VALUES (4, 'Wycofany po odwołaniu');
COMMIT;
