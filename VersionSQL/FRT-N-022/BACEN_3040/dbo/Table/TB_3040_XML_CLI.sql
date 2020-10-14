/****** Object:  Table [dbo].[TB_3040_XML_CLI]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_3040_XML_CLI](
	[ID_XML_CLI] [int] IDENTITY(1,1) NOT NULL,
	[AUTORZC] [varchar](1) NULL,
	[CD] [varchar](14) NOT NULL,
	[CLASSCLI] [varchar](2) NULL,
	[CONGECON] [varchar](40) NULL,
	[FATANUAL] [numeric](19, 2) NULL,
	[INIRELACTCLI] [date] NULL,
	[PORTECLI] [varchar](1) NULL,
	[TP] [varchar](1) NULL,
	[TPCTRL] [varchar](2) NULL,
	[ID_XML] [int] NOT NULL,
 CONSTRAINT [PK__XML_CLI] PRIMARY KEY CLUSTERED 
(
	[ID_XML_CLI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX__TB_3040_XML_CLI_1] ON [dbo].[TB_3040_XML_CLI]
(
	[ID_XML] ASC
)
INCLUDE ( 	[ID_XML_CLI],
	[CD]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_TB_3040_XML_CLI_1] ON [dbo].[TB_3040_XML_CLI]
(
	[ID_XML] ASC
)
INCLUDE ( 	[ID_XML_CLI],
	[CD]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_TB_3040_XML_CLI_2] ON [dbo].[TB_3040_XML_CLI]
(
	[CD] ASC,
	[ID_XML] ASC
)
INCLUDE ( 	[ID_XML_CLI]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[TB_3040_XML_CLI]  WITH CHECK ADD  CONSTRAINT [FK__XML_CLI__XML] FOREIGN KEY([ID_XML])
REFERENCES [dbo].[TB_3040_XML] ([ID_XML])
ALTER TABLE [dbo].[TB_3040_XML_CLI] CHECK CONSTRAINT [FK__XML_CLI__XML]