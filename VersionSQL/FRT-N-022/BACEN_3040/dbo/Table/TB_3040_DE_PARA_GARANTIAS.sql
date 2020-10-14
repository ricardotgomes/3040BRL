/****** Object:  Table [dbo].[TB_3040_DE_PARA_GARANTIAS]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_3040_DE_PARA_GARANTIAS](
	[ID_DE_PARA_GARANTIAS] [bigint] IDENTITY(1,1) NOT NULL,
	[ID_ANEXO_12] [int] NOT NULL,
	[DS_GARANTIAS] [varchar](1000) NOT NULL,
	[CREATED_BY] [varchar](100) NOT NULL,
	[CREATED_DATE] [datetime2](7) NOT NULL,
	[LAST_MODIFIED_BY] [varchar](100) NOT NULL,
	[LAST_MODIFIED_DATE] [datetime2](7) NOT NULL,
 CONSTRAINT [PK__DE_PARA_GARANTIAS] PRIMARY KEY CLUSTERED 
(
	[ID_DE_PARA_GARANTIAS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[TB_3040_DE_PARA_GARANTIAS]  WITH CHECK ADD  CONSTRAINT [FK__DE_PARA_GARANTIAS_ANEXO_12] FOREIGN KEY([ID_ANEXO_12])
REFERENCES [dbo].[TB_3040_ANEXO_12_GARANTIAS] ([ID_ANEXO_12])
ALTER TABLE [dbo].[TB_3040_DE_PARA_GARANTIAS] CHECK CONSTRAINT [FK__DE_PARA_GARANTIAS_ANEXO_12]