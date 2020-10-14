/****** Object:  Table [dbo].[TB_3040_XML_OP]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_3040_XML_OP](
	[ID_XML_OP] [int] IDENTITY(1,1) NOT NULL,
	[CARACESPECIAL] [varchar](40) NULL,
	[CEP] [varchar](8) NULL,
	[CLASSOP] [varchar](2) NULL,
	[CONTRT] [varchar](40) NULL,
	[COSIF] [varchar](100) NULL,
	[DETCLI] [varchar](14) NULL,
	[DIAATRASO] [int] NULL,
	[DTCONTR] [date] NULL,
	[DTVENCOP] [date] NULL,
	[INDX] [varchar](2) NULL,
	[MOD] [varchar](4) NULL,
	[NATUOP] [varchar](2) NULL,
	[ORIGEMREC] [varchar](4) NULL,
	[PERCINDX] [numeric](11, 7) NULL,
	[PROVCONSTTD] [numeric](19, 2) NULL,
	[TAXEFT] [numeric](11, 7) NULL,
	[VARCAMB] [varchar](3) NULL,
	[V20] [numeric](19, 2) NULL,
	[V40] [numeric](19, 2) NULL,
	[V60] [numeric](19, 2) NULL,
	[V80] [numeric](19, 2) NULL,
	[V110] [numeric](19, 2) NULL,
	[V120] [numeric](19, 2) NULL,
	[V130] [numeric](19, 2) NULL,
	[V140] [numeric](19, 2) NULL,
	[V150] [numeric](19, 2) NULL,
	[V160] [numeric](19, 2) NULL,
	[V165] [numeric](19, 2) NULL,
	[V170] [numeric](19, 2) NULL,
	[V175] [numeric](19, 2) NULL,
	[V180] [numeric](19, 2) NULL,
	[V190] [numeric](19, 2) NULL,
	[V199] [numeric](19, 2) NULL,
	[V205] [numeric](19, 2) NULL,
	[V210] [numeric](19, 2) NULL,
	[V220] [numeric](19, 2) NULL,
	[V230] [numeric](19, 2) NULL,
	[V240] [numeric](19, 2) NULL,
	[V245] [numeric](19, 2) NULL,
	[V250] [numeric](19, 2) NULL,
	[V255] [numeric](19, 2) NULL,
	[V260] [numeric](19, 2) NULL,
	[V270] [numeric](19, 2) NULL,
	[V280] [numeric](19, 2) NULL,
	[V290] [numeric](19, 2) NULL,
	[V310] [numeric](19, 2) NULL,
	[V320] [numeric](19, 2) NULL,
	[V330] [numeric](19, 2) NULL,
	[VLRCONTR] [numeric](19, 2) NULL,
	[ID_XML_CLI] [int] NOT NULL,
	[IPOC] [varchar](67) NULL,
	[DTAPROXPARCELA] [date] NULL,
	[VLRPROXPARCELA] [numeric](19, 2) NULL,
	[QTDPARCELAS] [int] NULL,
	[IS_BAIXA] [bit] NOT NULL,
 CONSTRAINT [PK__XML_OP] PRIMARY KEY CLUSTERED 
(
	[ID_XML_OP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_TB_3040_XML_OP_2] ON [dbo].[TB_3040_XML_OP]
(
	[CONTRT] ASC
)
INCLUDE ( 	[ID_XML_OP]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_XML_OP_1] ON [dbo].[TB_3040_XML_OP]
(
	[ID_XML_CLI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[TB_3040_XML_OP] ADD  DEFAULT ((0)) FOR [IS_BAIXA]
ALTER TABLE [dbo].[TB_3040_XML_OP]  WITH CHECK ADD  CONSTRAINT [FK__XML_OP__XML_CLI] FOREIGN KEY([ID_XML_CLI])
REFERENCES [dbo].[TB_3040_XML_CLI] ([ID_XML_CLI])
ALTER TABLE [dbo].[TB_3040_XML_OP] CHECK CONSTRAINT [FK__XML_OP__XML_CLI]