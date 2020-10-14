/****** Object:  Table [dbo].[TB_3040_DE_PARA_TP_CONTROLE]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_3040_DE_PARA_TP_CONTROLE](
	[ID_DE_PARA_TP_CONTROLE] [bigint] IDENTITY(1,1) NOT NULL,
	[ID_ANEXO_10] [int] NOT NULL,
	[DS_TP_CONTROLE] [varchar](30) NOT NULL,
	[CREATED_BY] [varchar](100) NOT NULL,
	[CREATED_DATE] [datetime2](7) NOT NULL,
	[LAST_MODIFIED_BY] [varchar](100) NOT NULL,
	[LAST_MODIFIED_DATE] [datetime2](7) NOT NULL,
 CONSTRAINT [PK__DE_PARA_TP_CONTROLE] PRIMARY KEY CLUSTERED 
(
	[ID_DE_PARA_TP_CONTROLE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[TB_3040_DE_PARA_TP_CONTROLE]  WITH CHECK ADD  CONSTRAINT [FK__DE_PARA_TP_CONTROLE_ANEXO_10] FOREIGN KEY([ID_ANEXO_10])
REFERENCES [dbo].[TB_3040_ANEXO_10_TP_CONTROLE] ([ID_ANEXO_10])
ALTER TABLE [dbo].[TB_3040_DE_PARA_TP_CONTROLE] CHECK CONSTRAINT [FK__DE_PARA_TP_CONTROLE_ANEXO_10]