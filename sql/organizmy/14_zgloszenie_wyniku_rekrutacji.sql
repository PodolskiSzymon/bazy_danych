-- Organizm 14: Zgłoszenie wyniku rekrutacji
-- Relacja kandydata o tym, co stało się po aplikacji, i przypomnienia, które go o to pytają.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG14_ReportOutcome (
    ReportOutcomeKey   NUMBER(2)     NOT NULL,
    ReportOutcomeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG14_RecruitmentReport (
    RecruitmentReportKey   NUMBER(11)  NOT NULL,
    CandidatePseudonymKey  NUMBER(10)  NOT NULL,
    JobPostingKey          NUMBER(10)  NOT NULL,
    ReportOutcomeKey       NUMBER(2)   NOT NULL,
    RecruitmentStageKey    NUMBER(2)   NOT NULL,
    ReportChannelKey       NUMBER(2)   NOT NULL,
    ReminderKey            NUMBER(11),
    ReportedAt             TIMESTAMP   NOT NULL
);

CREATE TABLE ORG14_Reminder (
    ReminderKey        NUMBER(11)  NOT NULL,
    ApplicationKey     NUMBER(12)  NOT NULL,
    ReminderStatusKey  NUMBER(2)   NOT NULL,
    ReminderNumber     NUMBER(1)   NOT NULL,
    SentAt             TIMESTAMP   NOT NULL
);

CREATE TABLE ORG14_RecruitmentStage (
    RecruitmentStageKey   NUMBER(2)     NOT NULL,
    RecruitmentStageName  VARCHAR2(40)  NOT NULL,
    StageRank             NUMBER(2)     NOT NULL
);

CREATE TABLE ORG14_ReportChannel (
    ReportChannelKey   NUMBER(2)     NOT NULL,
    ReportChannelName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG14_ReminderStatus (
    ReminderStatusKey   NUMBER(2)     NOT NULL,
    ReminderStatusName  VARCHAR2(40)  NOT NULL
);

COMMENT ON TABLE ORG14_ReportOutcome IS 'Wynik rekrutacji według kandydata.';
COMMENT ON COLUMN ORG14_ReportOutcome.ReportOutcomeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG14_ReportOutcome.ReportOutcomeName IS 'Nazwa wyniku';

COMMENT ON TABLE ORG14_RecruitmentReport IS 'Zgłoszenie wyniku rekrutacji – tylko dopisujemy, nie poprawiamy.';
COMMENT ON COLUMN ORG14_RecruitmentReport.RecruitmentReportKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG14_RecruitmentReport.CandidatePseudonymKey IS 'Kto zgłasza';
COMMENT ON COLUMN ORG14_RecruitmentReport.JobPostingKey IS 'Którego ogłoszenia dotyczy';
COMMENT ON COLUMN ORG14_RecruitmentReport.ReportOutcomeKey IS 'Wynik';
COMMENT ON COLUMN ORG14_RecruitmentReport.RecruitmentStageKey IS 'Na którym etapie się skończyło';
COMMENT ON COLUMN ORG14_RecruitmentReport.ReportChannelKey IS 'Jak zgłoszono';
COMMENT ON COLUMN ORG14_RecruitmentReport.ReminderKey IS 'Przypomnienie, po którym przyszło zgłoszenie';
COMMENT ON COLUMN ORG14_RecruitmentReport.ReportedAt IS 'Kiedy zgłoszono';

COMMENT ON TABLE ORG14_Reminder IS 'Przypomnienie wysłane kandydatowi przez platformę na naszą prośbę.';
COMMENT ON COLUMN ORG14_Reminder.ReminderKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG14_Reminder.ApplicationKey IS 'Aplikacja, o którą pytamy';
COMMENT ON COLUMN ORG14_Reminder.ReminderStatusKey IS 'Co się stało z przypomnieniem';
COMMENT ON COLUMN ORG14_Reminder.ReminderNumber IS 'Które to przypomnienie (1, 2…)';
COMMENT ON COLUMN ORG14_Reminder.SentAt IS 'Kiedy zlecono';

COMMENT ON TABLE ORG14_RecruitmentStage IS 'Etap rekrutacji.';
COMMENT ON COLUMN ORG14_RecruitmentStage.RecruitmentStageKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG14_RecruitmentStage.RecruitmentStageName IS 'Nazwa etapu';
COMMENT ON COLUMN ORG14_RecruitmentStage.StageRank IS 'Kolejność etapów';

COMMENT ON TABLE ORG14_ReportChannel IS 'Jak przyszło zgłoszenie.';
COMMENT ON COLUMN ORG14_ReportChannel.ReportChannelKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG14_ReportChannel.ReportChannelName IS 'Nazwa kanału';

COMMENT ON TABLE ORG14_ReminderStatus IS 'Los przypomnienia.';
COMMENT ON COLUMN ORG14_ReminderStatus.ReminderStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG14_ReminderStatus.ReminderStatusName IS 'Nazwa stanu przypomnienia';

ALTER TABLE ORG14_ReportOutcome ADD CONSTRAINT ORG14_ReportOutcome_PK PRIMARY KEY (ReportOutcomeKey);
ALTER TABLE ORG14_ReportOutcome ADD CONSTRAINT ORG14_ReportOutcome_ReportOutcomeName_UN UNIQUE (ReportOutcomeName);
ALTER TABLE ORG14_RecruitmentReport ADD CONSTRAINT ORG14_RecruitmentReport_PK PRIMARY KEY (RecruitmentReportKey);
ALTER TABLE ORG14_Reminder ADD CONSTRAINT ORG14_Reminder_PK PRIMARY KEY (ReminderKey);
ALTER TABLE ORG14_Reminder ADD CONSTRAINT ORG14_Reminder_UN UNIQUE (ApplicationKey, ReminderNumber);
ALTER TABLE ORG14_RecruitmentStage ADD CONSTRAINT ORG14_RecruitmentStage_PK PRIMARY KEY (RecruitmentStageKey);
ALTER TABLE ORG14_RecruitmentStage ADD CONSTRAINT ORG14_RecruitmentStage_RecruitmentStageName_UN UNIQUE (RecruitmentStageName);
ALTER TABLE ORG14_ReportChannel ADD CONSTRAINT ORG14_ReportChannel_PK PRIMARY KEY (ReportChannelKey);
ALTER TABLE ORG14_ReportChannel ADD CONSTRAINT ORG14_ReportChannel_ReportChannelName_UN UNIQUE (ReportChannelName);
ALTER TABLE ORG14_ReminderStatus ADD CONSTRAINT ORG14_ReminderStatus_PK PRIMARY KEY (ReminderStatusKey);
ALTER TABLE ORG14_ReminderStatus ADD CONSTRAINT ORG14_ReminderStatus_ReminderStatusName_UN UNIQUE (ReminderStatusName);

ALTER TABLE ORG14_RecruitmentReport ADD CONSTRAINT ORG14_RecruitmentReport_ReportOutcome_FK FOREIGN KEY (ReportOutcomeKey) REFERENCES ORG14_ReportOutcome (ReportOutcomeKey);
ALTER TABLE ORG14_RecruitmentReport ADD CONSTRAINT ORG14_RecruitmentReport_RecruitmentStage_FK FOREIGN KEY (RecruitmentStageKey) REFERENCES ORG14_RecruitmentStage (RecruitmentStageKey);
ALTER TABLE ORG14_RecruitmentReport ADD CONSTRAINT ORG14_RecruitmentReport_ReportChannel_FK FOREIGN KEY (ReportChannelKey) REFERENCES ORG14_ReportChannel (ReportChannelKey);
ALTER TABLE ORG14_RecruitmentReport ADD CONSTRAINT ORG14_RecruitmentReport_Reminder_FK FOREIGN KEY (ReminderKey) REFERENCES ORG14_Reminder (ReminderKey);
ALTER TABLE ORG14_Reminder ADD CONSTRAINT ORG14_Reminder_ReminderStatus_FK FOREIGN KEY (ReminderStatusKey) REFERENCES ORG14_ReminderStatus (ReminderStatusKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO ORG14_ReportOutcome (ReportOutcomeKey, ReportOutcomeName) VALUES (1, 'Brak odpowiedzi (cisza)');
INSERT INTO ORG14_ReportOutcome (ReportOutcomeKey, ReportOutcomeName) VALUES (2, 'Automatyczna odmowa');
INSERT INTO ORG14_ReportOutcome (ReportOutcomeKey, ReportOutcomeName) VALUES (3, 'Odmowa po rozmowie');
INSERT INTO ORG14_ReportOutcome (ReportOutcomeKey, ReportOutcomeName) VALUES (4, 'Oferta wycofana');
INSERT INTO ORG14_ReportOutcome (ReportOutcomeKey, ReportOutcomeName) VALUES (5, 'Zatrudnienie');
INSERT INTO ORG14_ReportOutcome (ReportOutcomeKey, ReportOutcomeName) VALUES (6, 'Ogłoszenie było nieaktualne');
INSERT INTO ORG14_RecruitmentStage (RecruitmentStageKey, RecruitmentStageName, StageRank) VALUES (1, 'Po wysłaniu CV', 1);
INSERT INTO ORG14_RecruitmentStage (RecruitmentStageKey, RecruitmentStageName, StageRank) VALUES (2, 'Po zadaniu lub teście', 2);
INSERT INTO ORG14_RecruitmentStage (RecruitmentStageKey, RecruitmentStageName, StageRank) VALUES (3, 'Po pierwszej rozmowie', 3);
INSERT INTO ORG14_RecruitmentStage (RecruitmentStageKey, RecruitmentStageName, StageRank) VALUES (4, 'Po kolejnej rozmowie', 4);
INSERT INTO ORG14_RecruitmentStage (RecruitmentStageKey, RecruitmentStageName, StageRank) VALUES (5, 'Po otrzymaniu oferty', 5);
INSERT INTO ORG14_ReportChannel (ReportChannelKey, ReportChannelName) VALUES (1, 'Formularz w widżecie');
INSERT INTO ORG14_ReportChannel (ReportChannelKey, ReportChannelName) VALUES (2, 'Odpowiedź na przypomnienie');
INSERT INTO ORG14_ReminderStatus (ReminderStatusKey, ReminderStatusName) VALUES (1, 'Zlecone platformie');
INSERT INTO ORG14_ReminderStatus (ReminderStatusKey, ReminderStatusName) VALUES (2, 'Dostarczone');
INSERT INTO ORG14_ReminderStatus (ReminderStatusKey, ReminderStatusName) VALUES (3, 'Bez odpowiedzi');
INSERT INTO ORG14_ReminderStatus (ReminderStatusKey, ReminderStatusName) VALUES (4, 'Kandydat odpowiedział');
COMMIT;
