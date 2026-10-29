-- Organizm 4: Odbiór danych z platformy
-- Każda dostawa danych: kiedy, którym endpointem, z jakim skutkiem – i surowa kopia każdego rekordu.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE DeliveryMode (
    DeliveryModeKey   NUMBER(2)     NOT NULL,
    DeliveryModeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE DeliveryStatus (
    DeliveryStatusKey   NUMBER(2)     NOT NULL,
    DeliveryStatusName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE DataDelivery (
    DataDeliveryKey    NUMBER(10)  NOT NULL,
    APIEndpointKey     NUMBER(6)   NOT NULL,
    DeliveryModeKey    NUMBER(2)   NOT NULL,
    DeliveryStatusKey  NUMBER(2)   NOT NULL,
    StartedAt          TIMESTAMP   NOT NULL,
    FinishedAt         TIMESTAMP,
    RecordsReceived    NUMBER(7),
    RecordsAccepted    NUMBER(7)
);

CREATE TABLE RawRecord (
    RawRecordKey      NUMBER(12)     NOT NULL,
    DataDeliveryKey   NUMBER(10)     NOT NULL,
    ExternalRecordId  VARCHAR2(100)  NOT NULL,
    RecordPayload     CLOB           NOT NULL,
    PayloadHash       VARCHAR2(64)   NOT NULL,
    ReceivedAt        TIMESTAMP      NOT NULL
);

CREATE TABLE DeliveryError (
    DeliveryErrorKey  NUMBER(10)     NOT NULL,
    DataDeliveryKey   NUMBER(10)     NOT NULL,
    RawRecordKey      NUMBER(12),
    ErrorTypeKey      NUMBER(2)      NOT NULL,
    ErrorMessage      VARCHAR2(400),
    OccurredAt        TIMESTAMP      NOT NULL
);

CREATE TABLE ErrorType (
    ErrorTypeKey   NUMBER(2)     NOT NULL,
    ErrorTypeName  VARCHAR2(40)  NOT NULL
);

COMMENT ON TABLE DeliveryMode IS 'Sposób, w jaki dane do nas trafiły.';
COMMENT ON COLUMN DeliveryMode.DeliveryModeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN DeliveryMode.DeliveryModeName IS 'Nazwa sposobu dostawy';

COMMENT ON TABLE DeliveryStatus IS 'Wynik dostawy.';
COMMENT ON COLUMN DeliveryStatus.DeliveryStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN DeliveryStatus.DeliveryStatusName IS 'Nazwa wyniku';

COMMENT ON TABLE DataDelivery IS 'Jedna dostawa danych jednym endpointem.';
COMMENT ON COLUMN DataDelivery.DataDeliveryKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN DataDelivery.APIEndpointKey IS 'Którym endpointem przyszły dane';
COMMENT ON COLUMN DataDelivery.DeliveryModeKey IS 'Sposób dostawy';
COMMENT ON COLUMN DataDelivery.DeliveryStatusKey IS 'Wynik dostawy';
COMMENT ON COLUMN DataDelivery.StartedAt IS 'Początek';
COMMENT ON COLUMN DataDelivery.FinishedAt IS 'Koniec';
COMMENT ON COLUMN DataDelivery.RecordsReceived IS 'Ile rekordów przyszło';
COMMENT ON COLUMN DataDelivery.RecordsAccepted IS 'Ile rekordów przyjęliśmy';

COMMENT ON TABLE RawRecord IS 'Rekord dokładnie w takiej postaci, w jakiej przyszedł od platformy.';
COMMENT ON COLUMN RawRecord.RawRecordKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN RawRecord.DataDeliveryKey IS 'Dostawa';
COMMENT ON COLUMN RawRecord.ExternalRecordId IS 'Numer rekordu u platformy';
COMMENT ON COLUMN RawRecord.RecordPayload IS 'Treść rekordu bez zmian (np. JSON)';
COMMENT ON COLUMN RawRecord.PayloadHash IS 'Skrót SHA-256 treści – do wykrywania duplikatów';
COMMENT ON COLUMN RawRecord.ReceivedAt IS 'Kiedy rekord przyszedł';

COMMENT ON TABLE DeliveryError IS 'Błąd dostawy albo pojedynczego rekordu.';
COMMENT ON COLUMN DeliveryError.DeliveryErrorKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN DeliveryError.DataDeliveryKey IS 'Dostawa';
COMMENT ON COLUMN DeliveryError.RawRecordKey IS 'Którego rekordu dotyczy (puste = całej dostawy)';
COMMENT ON COLUMN DeliveryError.ErrorTypeKey IS 'Rodzaj błędu';
COMMENT ON COLUMN DeliveryError.ErrorMessage IS 'Treść błędu';
COMMENT ON COLUMN DeliveryError.OccurredAt IS 'Kiedy wystąpił';

COMMENT ON TABLE ErrorType IS 'Rodzaj błędu przy odbiorze danych.';
COMMENT ON COLUMN ErrorType.ErrorTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ErrorType.ErrorTypeName IS 'Nazwa rodzaju błędu';

ALTER TABLE DeliveryMode ADD CONSTRAINT DeliveryMode_PK PRIMARY KEY (DeliveryModeKey);
ALTER TABLE DeliveryMode ADD CONSTRAINT DeliveryMode_DeliveryModeName_UN UNIQUE (DeliveryModeName);
ALTER TABLE DeliveryStatus ADD CONSTRAINT DeliveryStatus_PK PRIMARY KEY (DeliveryStatusKey);
ALTER TABLE DeliveryStatus ADD CONSTRAINT DeliveryStatus_DeliveryStatusName_UN UNIQUE (DeliveryStatusName);
ALTER TABLE DataDelivery ADD CONSTRAINT DataDelivery_PK PRIMARY KEY (DataDeliveryKey);
ALTER TABLE DataDelivery ADD CONSTRAINT DataDelivery_CK1 CHECK (RecordsAccepted <= RecordsReceived);
ALTER TABLE DataDelivery ADD CONSTRAINT DataDelivery_CK2 CHECK (FinishedAt IS NULL OR FinishedAt >= StartedAt);
ALTER TABLE RawRecord ADD CONSTRAINT RawRecord_PK PRIMARY KEY (RawRecordKey);
ALTER TABLE DeliveryError ADD CONSTRAINT DeliveryError_PK PRIMARY KEY (DeliveryErrorKey);
ALTER TABLE ErrorType ADD CONSTRAINT ErrorType_PK PRIMARY KEY (ErrorTypeKey);
ALTER TABLE ErrorType ADD CONSTRAINT ErrorType_ErrorTypeName_UN UNIQUE (ErrorTypeName);

ALTER TABLE DataDelivery ADD CONSTRAINT DataDelivery_DeliveryMode_FK FOREIGN KEY (DeliveryModeKey) REFERENCES DeliveryMode (DeliveryModeKey);
ALTER TABLE DataDelivery ADD CONSTRAINT DataDelivery_DeliveryStatus_FK FOREIGN KEY (DeliveryStatusKey) REFERENCES DeliveryStatus (DeliveryStatusKey);
ALTER TABLE RawRecord ADD CONSTRAINT RawRecord_DataDelivery_FK FOREIGN KEY (DataDeliveryKey) REFERENCES DataDelivery (DataDeliveryKey);
ALTER TABLE DeliveryError ADD CONSTRAINT DeliveryError_DataDelivery_FK FOREIGN KEY (DataDeliveryKey) REFERENCES DataDelivery (DataDeliveryKey);
ALTER TABLE DeliveryError ADD CONSTRAINT DeliveryError_RawRecord_FK FOREIGN KEY (RawRecordKey) REFERENCES RawRecord (RawRecordKey);
ALTER TABLE DeliveryError ADD CONSTRAINT DeliveryError_ErrorType_FK FOREIGN KEY (ErrorTypeKey) REFERENCES ErrorType (ErrorTypeKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO DeliveryMode (DeliveryModeKey, DeliveryModeName) VALUES (1, 'Pobranie według harmonogramu');
INSERT INTO DeliveryMode (DeliveryModeKey, DeliveryModeName) VALUES (2, 'Powiadomienie od platformy (webhook)');
INSERT INTO DeliveryMode (DeliveryModeKey, DeliveryModeName) VALUES (3, 'Plik z eksportem');
INSERT INTO DeliveryMode (DeliveryModeKey, DeliveryModeName) VALUES (4, 'Ręczne doładowanie historii');
INSERT INTO DeliveryStatus (DeliveryStatusKey, DeliveryStatusName) VALUES (1, 'W toku');
INSERT INTO DeliveryStatus (DeliveryStatusKey, DeliveryStatusName) VALUES (2, 'Zakończona');
INSERT INTO DeliveryStatus (DeliveryStatusKey, DeliveryStatusName) VALUES (3, 'Zakończona częściowo');
INSERT INTO DeliveryStatus (DeliveryStatusKey, DeliveryStatusName) VALUES (4, 'Nieudana');
INSERT INTO ErrorType (ErrorTypeKey, ErrorTypeName) VALUES (1, 'Brak wymaganego pola');
INSERT INTO ErrorType (ErrorTypeKey, ErrorTypeName) VALUES (2, 'Zły format danych');
INSERT INTO ErrorType (ErrorTypeKey, ErrorTypeName) VALUES (3, 'Odrzucony klucz API');
INSERT INTO ErrorType (ErrorTypeKey, ErrorTypeName) VALUES (4, 'Przekroczony limit zapytań');
INSERT INTO ErrorType (ErrorTypeKey, ErrorTypeName) VALUES (5, 'Brak odpowiedzi platformy');
INSERT INTO ErrorType (ErrorTypeKey, ErrorTypeName) VALUES (6, 'Nieznana wersja API');
COMMIT;
