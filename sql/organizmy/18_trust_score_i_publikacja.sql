-- Organizm 18: Trust Score i publikacja
-- Wynik firmy policzony konkretną metodą, z pewnością i powodami – oraz to, co wolno pokazać kandydatowi.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG18_ScoringMethodType (
    ScoringMethodTypeKey   NUMBER(2)     NOT NULL,
    ScoringMethodTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG18_ScoringMethod (
    ScoringMethodKey      NUMBER(4)     NOT NULL,
    ScoringMethodTypeKey  NUMBER(2)     NOT NULL,
    MethodVersion         VARCHAR2(20)  NOT NULL,
    ValidFrom             DATE          NOT NULL,
    ValidTo               DATE
);

CREATE TABLE ORG18_ScoringWeight (
    ScoringWeightKey  NUMBER(6)    NOT NULL,
    ScoringMethodKey  NUMBER(4)    NOT NULL,
    SignalTypeKey     NUMBER(3)    NOT NULL,
    WeightValue       NUMBER(5,3)  NOT NULL
);

CREATE TABLE ORG18_TrustScore (
    TrustScoreKey      NUMBER(11)   NOT NULL,
    SignalSnapshotKey  NUMBER(10)   NOT NULL,
    ScoringMethodKey   NUMBER(4)    NOT NULL,
    ScoreValue         NUMBER(3)    NOT NULL,
    ScoreConfidence    NUMBER(3,2)  NOT NULL,
    CalculatedAt       TIMESTAMP    NOT NULL
);

CREATE TABLE ORG18_ScoreReason (
    ScoreReasonKey  NUMBER(12)     NOT NULL,
    TrustScoreKey   NUMBER(11)     NOT NULL,
    SignalTypeKey   NUMBER(3)      NOT NULL,
    ReasonRank      NUMBER(1)      NOT NULL,
    ReasonText      VARCHAR2(300)  NOT NULL
);

CREATE TABLE ORG18_PublishedScore (
    PublishedScoreKey     NUMBER(10)  NOT NULL,
    TrustScoreKey         NUMBER(11)  NOT NULL,
    PublicationStatusKey  NUMBER(2)   NOT NULL,
    PublishedFrom         TIMESTAMP   NOT NULL,
    PublishedTo           TIMESTAMP
);

CREATE TABLE ORG18_PublicationStatus (
    PublicationStatusKey   NUMBER(2)     NOT NULL,
    PublicationStatusName  VARCHAR2(40)  NOT NULL
);

COMMENT ON TABLE ORG18_ScoringMethodType IS 'Rodzaj metody liczenia wyniku.';
COMMENT ON COLUMN ORG18_ScoringMethodType.ScoringMethodTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG18_ScoringMethodType.ScoringMethodTypeName IS 'Nazwa rodzaju metody';

COMMENT ON TABLE ORG18_ScoringMethod IS 'Metoda liczenia wyniku w konkretnej wersji.';
COMMENT ON COLUMN ORG18_ScoringMethod.ScoringMethodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG18_ScoringMethod.ScoringMethodTypeKey IS 'Rodzaj metody';
COMMENT ON COLUMN ORG18_ScoringMethod.MethodVersion IS 'Wersja';
COMMENT ON COLUMN ORG18_ScoringMethod.ValidFrom IS 'Od kiedy używana';
COMMENT ON COLUMN ORG18_ScoringMethod.ValidTo IS 'Do kiedy (puste = obecna)';

COMMENT ON TABLE ORG18_ScoringWeight IS 'Waga sygnału w danej metodzie – tabela łącząca z wartością.';
COMMENT ON COLUMN ORG18_ScoringWeight.ScoringWeightKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG18_ScoringWeight.ScoringMethodKey IS 'Metoda';
COMMENT ON COLUMN ORG18_ScoringWeight.SignalTypeKey IS 'Sygnał';
COMMENT ON COLUMN ORG18_ScoringWeight.WeightValue IS 'Waga';

COMMENT ON TABLE ORG18_TrustScore IS 'Wynik roboczy – każde przeliczenie to nowy wiersz.';
COMMENT ON COLUMN ORG18_TrustScore.TrustScoreKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG18_TrustScore.SignalSnapshotKey IS 'Na jakich danych liczono';
COMMENT ON COLUMN ORG18_TrustScore.ScoringMethodKey IS 'Jaką metodą';
COMMENT ON COLUMN ORG18_TrustScore.ScoreValue IS 'Wynik od 0 do 100';
COMMENT ON COLUMN ORG18_TrustScore.ScoreConfidence IS 'Pewność od 0 do 1';
COMMENT ON COLUMN ORG18_TrustScore.CalculatedAt IS 'Kiedy policzono';

COMMENT ON TABLE ORG18_ScoreReason IS 'Powód wyniku pokazywany kandydatowi i firmie.';
COMMENT ON COLUMN ORG18_ScoreReason.ScoreReasonKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG18_ScoreReason.TrustScoreKey IS 'Wynik';
COMMENT ON COLUMN ORG18_ScoreReason.SignalTypeKey IS 'Którego sygnału dotyczy';
COMMENT ON COLUMN ORG18_ScoreReason.ReasonRank IS 'Kolejność ważności';
COMMENT ON COLUMN ORG18_ScoreReason.ReasonText IS 'Tekst, np. „to samo ogłoszenie 7 razy w 9 miesięcy”';

COMMENT ON TABLE ORG18_PublishedScore IS 'Wynik pokazany publicznie – osobno od wyniku roboczego.';
COMMENT ON COLUMN ORG18_PublishedScore.PublishedScoreKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG18_PublishedScore.TrustScoreKey IS 'Który wynik pokazujemy';
COMMENT ON COLUMN ORG18_PublishedScore.PublicationStatusKey IS 'Stan publikacji';
COMMENT ON COLUMN ORG18_PublishedScore.PublishedFrom IS 'Od kiedy';
COMMENT ON COLUMN ORG18_PublishedScore.PublishedTo IS 'Do kiedy (puste = widoczny teraz)';

COMMENT ON TABLE ORG18_PublicationStatus IS 'Stan publikacji wyniku.';
COMMENT ON COLUMN ORG18_PublicationStatus.PublicationStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG18_PublicationStatus.PublicationStatusName IS 'Nazwa stanu publikacji';

ALTER TABLE ORG18_ScoringMethodType ADD CONSTRAINT ORG18_ScoringMethodType_PK PRIMARY KEY (ScoringMethodTypeKey);
ALTER TABLE ORG18_ScoringMethodType ADD CONSTRAINT ORG18_ScoringMethodType_ScoringMethodTypeName_UN UNIQUE (ScoringMethodTypeName);
ALTER TABLE ORG18_ScoringMethod ADD CONSTRAINT ORG18_ScoringMethod_PK PRIMARY KEY (ScoringMethodKey);
ALTER TABLE ORG18_ScoringMethod ADD CONSTRAINT ORG18_ScoringMethod_UN UNIQUE (ScoringMethodTypeKey, MethodVersion);
ALTER TABLE ORG18_ScoringWeight ADD CONSTRAINT ORG18_ScoringWeight_PK PRIMARY KEY (ScoringWeightKey);
ALTER TABLE ORG18_ScoringWeight ADD CONSTRAINT ORG18_ScoringWeight_UN UNIQUE (ScoringMethodKey, SignalTypeKey);
ALTER TABLE ORG18_TrustScore ADD CONSTRAINT ORG18_TrustScore_PK PRIMARY KEY (TrustScoreKey);
ALTER TABLE ORG18_TrustScore ADD CONSTRAINT ORG18_TrustScore_CK1 CHECK (ScoreValue BETWEEN 0 AND 100);
ALTER TABLE ORG18_TrustScore ADD CONSTRAINT ORG18_TrustScore_CK2 CHECK (ScoreConfidence BETWEEN 0 AND 1);
ALTER TABLE ORG18_ScoreReason ADD CONSTRAINT ORG18_ScoreReason_PK PRIMARY KEY (ScoreReasonKey);
ALTER TABLE ORG18_ScoreReason ADD CONSTRAINT ORG18_ScoreReason_UN UNIQUE (TrustScoreKey, ReasonRank);
ALTER TABLE ORG18_PublishedScore ADD CONSTRAINT ORG18_PublishedScore_PK PRIMARY KEY (PublishedScoreKey);
ALTER TABLE ORG18_PublishedScore ADD CONSTRAINT ORG18_PublishedScore_CK1 CHECK (PublishedTo IS NULL OR PublishedTo >= PublishedFrom);
ALTER TABLE ORG18_PublicationStatus ADD CONSTRAINT ORG18_PublicationStatus_PK PRIMARY KEY (PublicationStatusKey);
ALTER TABLE ORG18_PublicationStatus ADD CONSTRAINT ORG18_PublicationStatus_PublicationStatusName_UN UNIQUE (PublicationStatusName);

ALTER TABLE ORG18_ScoringMethod ADD CONSTRAINT ORG18_ScoringMethod_ScoringMethodType_FK FOREIGN KEY (ScoringMethodTypeKey) REFERENCES ORG18_ScoringMethodType (ScoringMethodTypeKey);
ALTER TABLE ORG18_ScoringWeight ADD CONSTRAINT ORG18_ScoringWeight_ScoringMethod_FK FOREIGN KEY (ScoringMethodKey) REFERENCES ORG18_ScoringMethod (ScoringMethodKey);
ALTER TABLE ORG18_TrustScore ADD CONSTRAINT ORG18_TrustScore_ScoringMethod_FK FOREIGN KEY (ScoringMethodKey) REFERENCES ORG18_ScoringMethod (ScoringMethodKey);
ALTER TABLE ORG18_ScoreReason ADD CONSTRAINT ORG18_ScoreReason_TrustScore_FK FOREIGN KEY (TrustScoreKey) REFERENCES ORG18_TrustScore (TrustScoreKey);
ALTER TABLE ORG18_PublishedScore ADD CONSTRAINT ORG18_PublishedScore_TrustScore_FK FOREIGN KEY (TrustScoreKey) REFERENCES ORG18_TrustScore (TrustScoreKey);
ALTER TABLE ORG18_PublishedScore ADD CONSTRAINT ORG18_PublishedScore_PublicationStatus_FK FOREIGN KEY (PublicationStatusKey) REFERENCES ORG18_PublicationStatus (PublicationStatusKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO ORG18_ScoringMethodType (ScoringMethodTypeKey, ScoringMethodTypeName) VALUES (1, 'Wagi ustalone przez zespół');
INSERT INTO ORG18_ScoringMethodType (ScoringMethodTypeKey, ScoringMethodTypeName) VALUES (2, 'Wytrenowany model');
INSERT INTO ORG18_ScoringMethod (ScoringMethodKey, ScoringMethodTypeKey, MethodVersion, ValidFrom, ValidTo) VALUES (1, 1, '1.0', DATE '2026-12-01', NULL);
INSERT INTO ORG18_PublicationStatus (PublicationStatusKey, PublicationStatusName) VALUES (1, 'Opublikowany');
INSERT INTO ORG18_PublicationStatus (PublicationStatusKey, PublicationStatusName) VALUES (2, 'Za mało danych');
INSERT INTO ORG18_PublicationStatus (PublicationStatusKey, PublicationStatusName) VALUES (3, 'Wstrzymany do decyzji moderatora');
INSERT INTO ORG18_PublicationStatus (PublicationStatusKey, PublicationStatusName) VALUES (4, 'Wycofany po odwołaniu');
COMMIT;
