-- Organizm 9: Warunki zatrudnienia
-- Na jakiej umowie, za ile i z jakimi dodatkami – obietnica, którą firma składa w ogłoszeniu.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE Currency (
    CurrencyKey   NUMBER(3)     NOT NULL,
    CurrencyCode  CHAR(3)       NOT NULL,
    CurrencyName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ContractType (
    ContractTypeKey   NUMBER(2)     NOT NULL,
    ContractTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE SalaryPeriod (
    SalaryPeriodKey   NUMBER(2)     NOT NULL,
    SalaryPeriodName  VARCHAR2(20)  NOT NULL
);

CREATE TABLE PostingSalary (
    PostingSalaryKey  NUMBER(11)    NOT NULL,
    JobPostingKey     NUMBER(10)    NOT NULL,
    ContractTypeKey   NUMBER(2)     NOT NULL,
    SalaryFrom        NUMBER(10,2),
    SalaryTo          NUMBER(10,2),
    CurrencyKey       NUMBER(3),
    SalaryPeriodKey   NUMBER(2),
    IsGross           CHAR(1)
);

CREATE TABLE PostingBenefit (
    PostingBenefitKey  NUMBER(11)  NOT NULL,
    JobPostingKey      NUMBER(10)  NOT NULL,
    BenefitKey         NUMBER(4)   NOT NULL
);

CREATE TABLE Benefit (
    BenefitKey          NUMBER(4)     NOT NULL,
    BenefitName         VARCHAR2(80)  NOT NULL,
    BenefitCategoryKey  NUMBER(2)     NOT NULL
);

CREATE TABLE BenefitCategory (
    BenefitCategoryKey   NUMBER(2)     NOT NULL,
    BenefitCategoryName  VARCHAR2(30)  NOT NULL
);

COMMENT ON TABLE Currency IS 'Waluta.';
COMMENT ON COLUMN Currency.CurrencyKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN Currency.CurrencyCode IS 'Kod waluty ISO, np. PLN';
COMMENT ON COLUMN Currency.CurrencyName IS 'Nazwa waluty';

COMMENT ON TABLE ContractType IS 'Rodzaj umowy.';
COMMENT ON COLUMN ContractType.ContractTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ContractType.ContractTypeName IS 'Nazwa rodzaju umowy';

COMMENT ON TABLE SalaryPeriod IS 'Okres, za który podano kwotę.';
COMMENT ON COLUMN SalaryPeriod.SalaryPeriodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN SalaryPeriod.SalaryPeriodName IS 'Nazwa okresu';

COMMENT ON TABLE PostingSalary IS 'Umowa z widełkami w ogłoszeniu – jedno ogłoszenie może mieć kilka takich wierszy.';
COMMENT ON COLUMN PostingSalary.PostingSalaryKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN PostingSalary.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN PostingSalary.ContractTypeKey IS 'Rodzaj umowy';
COMMENT ON COLUMN PostingSalary.SalaryFrom IS 'Widełki od (puste = nie podano)';
COMMENT ON COLUMN PostingSalary.SalaryTo IS 'Widełki do';
COMMENT ON COLUMN PostingSalary.CurrencyKey IS 'Waluta (puste, gdy brak kwoty)';
COMMENT ON COLUMN PostingSalary.SalaryPeriodKey IS 'Za jaki okres (puste, gdy brak kwoty)';
COMMENT ON COLUMN PostingSalary.IsGross IS 'Czy kwota jest brutto';

COMMENT ON TABLE PostingBenefit IS 'Benefit w ogłoszeniu – tabela łącząca ogłoszenia z benefitami.';
COMMENT ON COLUMN PostingBenefit.PostingBenefitKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN PostingBenefit.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN PostingBenefit.BenefitKey IS 'Benefit';

COMMENT ON TABLE Benefit IS 'Dodatek do pracy, np. prywatna opieka medyczna.';
COMMENT ON COLUMN Benefit.BenefitKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN Benefit.BenefitName IS 'Nazwa benefitu';
COMMENT ON COLUMN Benefit.BenefitCategoryKey IS 'Grupa benefitu';

COMMENT ON TABLE BenefitCategory IS 'Grupa benefitów.';
COMMENT ON COLUMN BenefitCategory.BenefitCategoryKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN BenefitCategory.BenefitCategoryName IS 'Nazwa grupy';

ALTER TABLE Currency ADD CONSTRAINT Currency_PK PRIMARY KEY (CurrencyKey);
ALTER TABLE Currency ADD CONSTRAINT Currency_CurrencyCode_UN UNIQUE (CurrencyCode);
ALTER TABLE ContractType ADD CONSTRAINT ContractType_PK PRIMARY KEY (ContractTypeKey);
ALTER TABLE ContractType ADD CONSTRAINT ContractType_ContractTypeName_UN UNIQUE (ContractTypeName);
ALTER TABLE SalaryPeriod ADD CONSTRAINT SalaryPeriod_PK PRIMARY KEY (SalaryPeriodKey);
ALTER TABLE SalaryPeriod ADD CONSTRAINT SalaryPeriod_SalaryPeriodName_UN UNIQUE (SalaryPeriodName);
ALTER TABLE PostingSalary ADD CONSTRAINT PostingSalary_PK PRIMARY KEY (PostingSalaryKey);
ALTER TABLE PostingSalary ADD CONSTRAINT PostingSalary_UN UNIQUE (JobPostingKey, ContractTypeKey);
ALTER TABLE PostingSalary ADD CONSTRAINT PostingSalary_IsGross_CK CHECK (IsGross IN ('T', 'N'));
ALTER TABLE PostingSalary ADD CONSTRAINT PostingSalary_CK1 CHECK (SalaryFrom IS NULL OR SalaryTo IS NULL OR SalaryFrom <= SalaryTo);
ALTER TABLE PostingBenefit ADD CONSTRAINT PostingBenefit_PK PRIMARY KEY (PostingBenefitKey);
ALTER TABLE PostingBenefit ADD CONSTRAINT PostingBenefit_UN UNIQUE (JobPostingKey, BenefitKey);
ALTER TABLE Benefit ADD CONSTRAINT Benefit_PK PRIMARY KEY (BenefitKey);
ALTER TABLE Benefit ADD CONSTRAINT Benefit_BenefitName_UN UNIQUE (BenefitName);
ALTER TABLE BenefitCategory ADD CONSTRAINT BenefitCategory_PK PRIMARY KEY (BenefitCategoryKey);
ALTER TABLE BenefitCategory ADD CONSTRAINT BenefitCategory_BenefitCategoryName_UN UNIQUE (BenefitCategoryName);

ALTER TABLE PostingSalary ADD CONSTRAINT PostingSalary_ContractType_FK FOREIGN KEY (ContractTypeKey) REFERENCES ContractType (ContractTypeKey);
ALTER TABLE PostingSalary ADD CONSTRAINT PostingSalary_Currency_FK FOREIGN KEY (CurrencyKey) REFERENCES Currency (CurrencyKey);
ALTER TABLE PostingSalary ADD CONSTRAINT PostingSalary_SalaryPeriod_FK FOREIGN KEY (SalaryPeriodKey) REFERENCES SalaryPeriod (SalaryPeriodKey);
ALTER TABLE PostingBenefit ADD CONSTRAINT PostingBenefit_Benefit_FK FOREIGN KEY (BenefitKey) REFERENCES Benefit (BenefitKey);
ALTER TABLE Benefit ADD CONSTRAINT Benefit_BenefitCategory_FK FOREIGN KEY (BenefitCategoryKey) REFERENCES BenefitCategory (BenefitCategoryKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO Currency (CurrencyKey, CurrencyCode, CurrencyName) VALUES (1, 'PLN', 'złoty');
INSERT INTO Currency (CurrencyKey, CurrencyCode, CurrencyName) VALUES (2, 'EUR', 'euro');
INSERT INTO Currency (CurrencyKey, CurrencyCode, CurrencyName) VALUES (3, 'USD', 'dolar amerykański');
INSERT INTO Currency (CurrencyKey, CurrencyCode, CurrencyName) VALUES (4, 'GBP', 'funt brytyjski');
INSERT INTO ContractType (ContractTypeKey, ContractTypeName) VALUES (1, 'Umowa o pracę');
INSERT INTO ContractType (ContractTypeKey, ContractTypeName) VALUES (2, 'Kontrakt B2B');
INSERT INTO ContractType (ContractTypeKey, ContractTypeName) VALUES (3, 'Umowa zlecenie');
INSERT INTO ContractType (ContractTypeKey, ContractTypeName) VALUES (4, 'Umowa o dzieło');
INSERT INTO ContractType (ContractTypeKey, ContractTypeName) VALUES (5, 'Staż lub praktyki');
INSERT INTO ContractType (ContractTypeKey, ContractTypeName) VALUES (6, 'Umowa na zastępstwo');
INSERT INTO SalaryPeriod (SalaryPeriodKey, SalaryPeriodName) VALUES (1, 'Za godzinę');
INSERT INTO SalaryPeriod (SalaryPeriodKey, SalaryPeriodName) VALUES (2, 'Miesięcznie');
INSERT INTO SalaryPeriod (SalaryPeriodKey, SalaryPeriodName) VALUES (3, 'Rocznie');
INSERT INTO SalaryPeriod (SalaryPeriodKey, SalaryPeriodName) VALUES (4, 'Za projekt');
INSERT INTO BenefitCategory (BenefitCategoryKey, BenefitCategoryName) VALUES (1, 'Zdrowie');
INSERT INTO BenefitCategory (BenefitCategoryKey, BenefitCategoryName) VALUES (2, 'Sport i rekreacja');
INSERT INTO BenefitCategory (BenefitCategoryKey, BenefitCategoryName) VALUES (3, 'Rozwój');
INSERT INTO BenefitCategory (BenefitCategoryKey, BenefitCategoryName) VALUES (4, 'Elastyczność');
INSERT INTO BenefitCategory (BenefitCategoryKey, BenefitCategoryName) VALUES (5, 'Finanse');
INSERT INTO Benefit (BenefitKey, BenefitName, BenefitCategoryKey) VALUES (1, 'Prywatna opieka medyczna', 1);
INSERT INTO Benefit (BenefitKey, BenefitName, BenefitCategoryKey) VALUES (2, 'Karta sportowa', 2);
INSERT INTO Benefit (BenefitKey, BenefitName, BenefitCategoryKey) VALUES (3, 'Budżet szkoleniowy', 3);
INSERT INTO Benefit (BenefitKey, BenefitName, BenefitCategoryKey) VALUES (4, 'Elastyczne godziny pracy', 4);
INSERT INTO Benefit (BenefitKey, BenefitName, BenefitCategoryKey) VALUES (5, 'Premia roczna', 5);
COMMIT;
