-- Organizm 4: Odbiór danych z platformy
-- Każda dostawa danych: kiedy, którym endpointem, z jakim skutkiem – i surowa kopia każdego rekordu.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG04_DeliveryMode (
    DeliveryModeKey   NUMBER(2)     NOT NULL,
    DeliveryModeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG04_DeliveryStatus (
    DeliveryStatusKey   NUMBER(2)     NOT NULL,
    DeliveryStatusName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE ORG04_DataDelivery (
    DataDeliveryKey    NUMBER(10)  NOT NULL,
    APIEndpointKey     NUMBER(6)   NOT NULL,
    DeliveryModeKey    NUMBER(2)   NOT NULL,
    DeliveryStatusKey  NUMBER(2)   NOT NULL,
    StartedAt          TIMESTAMP   NOT NULL,
    FinishedAt         TIMESTAMP,
    RecordsReceived    NUMBER(7),
    RecordsAccepted    NUMBER(7)
);

CREATE TABLE ORG04_RawRecord (
    RawRecordKey      NUMBER(12)     NOT NULL,
    DataDeliveryKey   NUMBER(10)     NOT NULL,
    ExternalRecordId  VARCHAR2(100)  NOT NULL,
    RecordPayload     CLOB           NOT NULL,
    PayloadHash       VARCHAR2(64)   NOT NULL,
    ReceivedAt        TIMESTAMP      NOT NULL
);

CREATE TABLE ORG04_DeliveryError (
    DeliveryErrorKey  NUMBER(10)     NOT NULL,
    DataDeliveryKey   NUMBER(10)     NOT NULL,
    RawRecordKey      NUMBER(12),
    ErrorTypeKey      NUMBER(2)      NOT NULL,
    ErrorMessage      VARCHAR2(400),
    OccurredAt        TIMESTAMP      NOT NULL
);

CREATE TABLE ORG04_ErrorType (
    ErrorTypeKey   NUMBER(2)     NOT NULL,
    ErrorTypeName  VARCHAR2(40)  NOT NULL
);

COMMENT ON TABLE ORG04_DeliveryMode IS 'Sposób, w jaki dane do nas trafiły.';
COMMENT ON COLUMN ORG04_DeliveryMode.DeliveryModeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG04_DeliveryMode.DeliveryModeName IS 'Nazwa sposobu dostawy';

COMMENT ON TABLE ORG04_DeliveryStatus IS 'Wynik dostawy.';
COMMENT ON COLUMN ORG04_DeliveryStatus.DeliveryStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG04_DeliveryStatus.DeliveryStatusName IS 'Nazwa wyniku';

COMMENT ON TABLE ORG04_DataDelivery IS 'Jedna dostawa danych jednym endpointem.';
COMMENT ON COLUMN ORG04_DataDelivery.DataDeliveryKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG04_DataDelivery.APIEndpointKey IS 'Którym endpointem przyszły dane';
COMMENT ON COLUMN ORG04_DataDelivery.DeliveryModeKey IS 'Sposób dostawy';
COMMENT ON COLUMN ORG04_DataDelivery.DeliveryStatusKey IS 'Wynik dostawy';
COMMENT ON COLUMN ORG04_DataDelivery.StartedAt IS 'Początek';
COMMENT ON COLUMN ORG04_DataDelivery.FinishedAt IS 'Koniec';
COMMENT ON COLUMN ORG04_DataDelivery.RecordsReceived IS 'Ile rekordów przyszło';
COMMENT ON COLUMN ORG04_DataDelivery.RecordsAccepted IS 'Ile rekordów przyjęliśmy';

COMMENT ON TABLE ORG04_RawRecord IS 'Rekord dokładnie w takiej postaci, w jakiej przyszedł od platformy.';
COMMENT ON COLUMN ORG04_RawRecord.RawRecordKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG04_RawRecord.DataDeliveryKey IS 'Dostawa';
COMMENT ON COLUMN ORG04_RawRecord.ExternalRecordId IS 'Numer rekordu u platformy';
COMMENT ON COLUMN ORG04_RawRecord.RecordPayload IS 'Treść rekordu bez zmian (np. JSON)';
COMMENT ON COLUMN ORG04_RawRecord.PayloadHash IS 'Skrót SHA-256 treści – do wykrywania duplikatów';
COMMENT ON COLUMN ORG04_RawRecord.ReceivedAt IS 'Kiedy rekord przyszedł';

COMMENT ON TABLE ORG04_DeliveryError IS 'Błąd dostawy albo pojedynczego rekordu.';
COMMENT ON COLUMN ORG04_DeliveryError.DeliveryErrorKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG04_DeliveryError.DataDeliveryKey IS 'Dostawa';
COMMENT ON COLUMN ORG04_DeliveryError.RawRecordKey IS 'Którego rekordu dotyczy (puste = całej dostawy)';
COMMENT ON COLUMN ORG04_DeliveryError.ErrorTypeKey IS 'Rodzaj błędu';
COMMENT ON COLUMN ORG04_DeliveryError.ErrorMessage IS 'Treść błędu';
COMMENT ON COLUMN ORG04_DeliveryError.OccurredAt IS 'Kiedy wystąpił';

COMMENT ON TABLE ORG04_ErrorType IS 'Rodzaj błędu przy odbiorze danych.';
COMMENT ON COLUMN ORG04_ErrorType.ErrorTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG04_ErrorType.ErrorTypeName IS 'Nazwa rodzaju błędu';

ALTER TABLE ORG04_DeliveryMode ADD CONSTRAINT ORG04_DeliveryMode_PK PRIMARY KEY (DeliveryModeKey);
ALTER TABLE ORG04_DeliveryMode ADD CONSTRAINT ORG04_DeliveryMode_DeliveryModeName_UN UNIQUE (DeliveryModeName);
ALTER TABLE ORG04_DeliveryStatus ADD CONSTRAINT ORG04_DeliveryStatus_PK PRIMARY KEY (DeliveryStatusKey);
ALTER TABLE ORG04_DeliveryStatus ADD CONSTRAINT ORG04_DeliveryStatus_DeliveryStatusName_UN UNIQUE (DeliveryStatusName);
ALTER TABLE ORG04_DataDelivery ADD CONSTRAINT ORG04_DataDelivery_PK PRIMARY KEY (DataDeliveryKey);
ALTER TABLE ORG04_DataDelivery ADD CONSTRAINT ORG04_DataDelivery_CK1 CHECK (RecordsAccepted <= RecordsReceived);
ALTER TABLE ORG04_DataDelivery ADD CONSTRAINT ORG04_DataDelivery_CK2 CHECK (FinishedAt IS NULL OR FinishedAt >= StartedAt);
ALTER TABLE ORG04_RawRecord ADD CONSTRAINT ORG04_RawRecord_PK PRIMARY KEY (RawRecordKey);
ALTER TABLE ORG04_DeliveryError ADD CONSTRAINT ORG04_DeliveryError_PK PRIMARY KEY (DeliveryErrorKey);
ALTER TABLE ORG04_ErrorType ADD CONSTRAINT ORG04_ErrorType_PK PRIMARY KEY (ErrorTypeKey);
ALTER TABLE ORG04_ErrorType ADD CONSTRAINT ORG04_ErrorType_ErrorTypeName_UN UNIQUE (ErrorTypeName);

ALTER TABLE ORG04_DataDelivery ADD CONSTRAINT ORG04_DataDelivery_DeliveryMode_FK FOREIGN KEY (DeliveryModeKey) REFERENCES ORG04_DeliveryMode (DeliveryModeKey);
ALTER TABLE ORG04_DataDelivery ADD CONSTRAINT ORG04_DataDelivery_DeliveryStatus_FK FOREIGN KEY (DeliveryStatusKey) REFERENCES ORG04_DeliveryStatus (DeliveryStatusKey);
ALTER TABLE ORG04_RawRecord ADD CONSTRAINT ORG04_RawRecord_DataDelivery_FK FOREIGN KEY (DataDeliveryKey) REFERENCES ORG04_DataDelivery (DataDeliveryKey);
ALTER TABLE ORG04_DeliveryError ADD CONSTRAINT ORG04_DeliveryError_DataDelivery_FK FOREIGN KEY (DataDeliveryKey) REFERENCES ORG04_DataDelivery (DataDeliveryKey);
ALTER TABLE ORG04_DeliveryError ADD CONSTRAINT ORG04_DeliveryError_RawRecord_FK FOREIGN KEY (RawRecordKey) REFERENCES ORG04_RawRecord (RawRecordKey);
ALTER TABLE ORG04_DeliveryError ADD CONSTRAINT ORG04_DeliveryError_ErrorType_FK FOREIGN KEY (ErrorTypeKey) REFERENCES ORG04_ErrorType (ErrorTypeKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO ORG04_DeliveryMode (DeliveryModeKey, DeliveryModeName) VALUES (1, 'Pobranie według harmonogramu');
INSERT INTO ORG04_DeliveryMode (DeliveryModeKey, DeliveryModeName) VALUES (2, 'Powiadomienie od platformy (webhook)');
INSERT INTO ORG04_DeliveryMode (DeliveryModeKey, DeliveryModeName) VALUES (3, 'Plik z eksportem');
INSERT INTO ORG04_DeliveryMode (DeliveryModeKey, DeliveryModeName) VALUES (4, 'Ręczne doładowanie historii');
INSERT INTO ORG04_DeliveryStatus (DeliveryStatusKey, DeliveryStatusName) VALUES (1, 'W toku');
INSERT INTO ORG04_DeliveryStatus (DeliveryStatusKey, DeliveryStatusName) VALUES (2, 'Zakończona');
INSERT INTO ORG04_DeliveryStatus (DeliveryStatusKey, DeliveryStatusName) VALUES (3, 'Zakończona częściowo');
INSERT INTO ORG04_DeliveryStatus (DeliveryStatusKey, DeliveryStatusName) VALUES (4, 'Nieudana');
INSERT INTO ORG04_ErrorType (ErrorTypeKey, ErrorTypeName) VALUES (1, 'Brak wymaganego pola');
INSERT INTO ORG04_ErrorType (ErrorTypeKey, ErrorTypeName) VALUES (2, 'Zły format danych');
INSERT INTO ORG04_ErrorType (ErrorTypeKey, ErrorTypeName) VALUES (3, 'Odrzucony klucz API');
INSERT INTO ORG04_ErrorType (ErrorTypeKey, ErrorTypeName) VALUES (4, 'Przekroczony limit zapytań');
INSERT INTO ORG04_ErrorType (ErrorTypeKey, ErrorTypeName) VALUES (5, 'Brak odpowiedzi platformy');
INSERT INTO ORG04_ErrorType (ErrorTypeKey, ErrorTypeName) VALUES (6, 'Nieznana wersja API');
COMMIT;
