/****** Object:  Table [dbo].[TB_3040_DE_PARA_TP_PESSOA]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_3040_DE_PARA_TP_PESSOA](
	[ID_DE_PARA_TP_PESSOA] [bigint] IDENTITY(1,1) NOT NULL,
	[ID_ANEXO_11] [int] NOT NULL,
	[DS_TP_PESSOA] [varchar](30) NOT NULL,
	[CREATED_BY] [varchar](100) NOT NULL,
	[CREATED_DATE] [datetime2](7) NOT NULL,
	[LAST_MODIFIED_BY] [varchar](100) NOT NULL,
	[LAST_MODIFIED_DATE] [datetime2](7) NOT NULL,
 CONSTRAINT [PK__DE_PARA_TP_PESSOA] PRIMARY KEY CLUSTERED 
(
	[ID_DE_PARA_TP_PESSOA] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[TB_3040_DE_PARA_TP_PESSOA]  WITH CHECK ADD  CONSTRAINT [FK__DE_PARA_TP_PESSOA_ANEXO_11] FOREIGN KEY([ID_ANEXO_11])
REFERENCES [dbo].[TB_3040_ANEXO_11_TP_PESSOA] ([ID_ANEXO_11])
ALTER TABLE [dbo].[TB_3040_DE_PARA_TP_PESSOA] CHECK CONSTRAINT [FK__DE_PARA_TP_PESSOA_ANEXO_11]