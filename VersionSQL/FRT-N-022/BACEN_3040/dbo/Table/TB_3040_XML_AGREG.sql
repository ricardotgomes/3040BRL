/****** Object:  Table [dbo].[TB_3040_XML_AGREG]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_3040_XML_AGREG](
	[ID_XML_AGREG] [int] IDENTITY(1,1) NOT NULL,
	[CARACESPECIAL] [varchar](40) NULL,
	[CLASSOP] [varchar](2) NULL,
	[DESEMPOP] [varchar](2) NULL,
	[FAIXAVLR] [varchar](1) NULL,
	[LOCALIZ] [varchar](5) NULL,
	[MOD] [varchar](4) NULL,
	[NATUOP] [varchar](2) NULL,
	[ORIGEMREC] [varchar](4) NULL,
	[PROVCONSTTD] [numeric](19, 2) NULL,
	[PRZPROVM] [varchar](1) NULL,
	[QTDCLI] [int] NULL,
	[QTDOP] [int] NULL,
	[TPCLI] [varchar](1) NULL,
	[TPCTRL] [varchar](2) NULL,
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
	[VINCME] [varchar](1) NULL,
	[ID_XML] [int] NOT NULL,
 CONSTRAINT [PK__XML_AGREG] PRIMARY KEY CLUSTERED 
(
	[ID_XML_AGREG] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[TB_3040_XML_AGREG]  WITH CHECK ADD  CONSTRAINT [FK__XML_AGREG__XML] FOREIGN KEY([ID_XML])
REFERENCES [dbo].[TB_3040_XML] ([ID_XML])
ALTER TABLE [dbo].[TB_3040_XML_AGREG] CHECK CONSTRAINT [FK__XML_AGREG__XML]