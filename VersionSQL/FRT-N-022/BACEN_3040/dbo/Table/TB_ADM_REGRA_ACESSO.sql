/****** Object:  Table [dbo].[TB_ADM_REGRA_ACESSO]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_ADM_REGRA_ACESSO](
	[ID_REGRA_ACESSO] [int] IDENTITY(1,1) NOT NULL,
	[ID_PERFIL_ACESSO] [int] NULL,
	[TP_ACESSO] [varchar](10) NOT NULL,
	[NM_ACESSO] [varchar](50) NOT NULL,
	[DS_ACESSO] [varchar](50) NOT NULL,
	[IS_ALTERAR] [bit] NULL,
	[IS_EXCLUIR] [bit] NULL,
	[IS_INCLUIR] [bit] NULL,
	[IS_PROCESSAR] [bit] NULL,
	[IS_VISUALIZAR] [bit] NULL,
	[CREATED_BY] [varchar](100) NOT NULL,
	[CREATED_DATE] [datetime2](7) NOT NULL,
	[LAST_MODIFIED_BY] [varchar](100) NULL,
	[LAST_MODIFIED_DATE] [datetime2](7) NULL,
 CONSTRAINT [PK__ADM_REGRA_ACESSO] PRIMARY KEY CLUSTERED 
(
	[ID_REGRA_ACESSO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[TB_ADM_REGRA_ACESSO]  WITH CHECK ADD  CONSTRAINT [FK__TB_ADM_REGRA_ACESSO__TB_ADM_PERFIL_ACESSO] FOREIGN KEY([ID_PERFIL_ACESSO])
REFERENCES [dbo].[TB_ADM_PERFIL_ACESSO] ([ID_PERFIL_ACESSO])
ALTER TABLE [dbo].[TB_ADM_REGRA_ACESSO] CHECK CONSTRAINT [FK__TB_ADM_REGRA_ACESSO__TB_ADM_PERFIL_ACESSO]