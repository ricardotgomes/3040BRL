/****** Object:  Table [dbo].[TB_3040_DE_PARA_CLASS_RISCO_OPER]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_3040_DE_PARA_CLASS_RISCO_OPER](
	[ID_DE_PARA_CLASS_RISCO_OPER] [bigint] IDENTITY(1,1) NOT NULL,
	[ID_ANEXO_17] [int] NOT NULL,
	[DS_CLASS_RISCO_OPER] [varchar](60) NOT NULL,
	[CREATED_BY] [varchar](100) NOT NULL,
	[CREATED_DATE] [datetime2](7) NOT NULL,
	[LAST_MODIFIED_BY] [varchar](100) NOT NULL,
	[LAST_MODIFIED_DATE] [datetime2](7) NOT NULL,
 CONSTRAINT [PK__DE_PARA_CLASS_RISCO_OPER] PRIMARY KEY CLUSTERED 
(
	[ID_DE_PARA_CLASS_RISCO_OPER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[TB_3040_DE_PARA_CLASS_RISCO_OPER]  WITH CHECK ADD  CONSTRAINT [FK__DE_PARA_CLASS_RISCO_OPER_ANEXO_17] FOREIGN KEY([ID_ANEXO_17])
REFERENCES [dbo].[TB_3040_ANEXO_17_CLASS_RISCO_OPER] ([ID_ANEXO_17])
ALTER TABLE [dbo].[TB_3040_DE_PARA_CLASS_RISCO_OPER] CHECK CONSTRAINT [FK__DE_PARA_CLASS_RISCO_OPER_ANEXO_17]