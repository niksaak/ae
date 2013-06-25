{
  AE - VN Tools
  © 2007-2013 WinKiller Studio and The Contributors.
  This software is free. Please see License for details.

  Archive format initialisation

  Written by dsp2003.
}

unit AnimED_Archives_Init;

interface

uses AA_RFA, // main module

     AA_AFS,
     AA_AHFS,
     AA_ALD_AliceSoft,         // 2011/03/22
     AA_AOS_Lilim,
     AA_ARC_Alcot,
     AA_ARC_CRC,               // 2010/05/10
     AA_ARC_DK42007,           // 2011/04/26
     AA_ARC_Ethornell_BGI,
     AA_GROOVER_ARC,
     AA_ARC_KISS,              // 2010/06/06
     AA_ARC_MAI,               // 2011/04/26
     AA_ARC_Majiro,
     AA_ARC_MikoMai,           // 2010/08/18
     AA_ARC_RPM,
     AA_ARC_Will,
     AA_BIN_ACPXPK01,          // 2010/06/12
     AA_BIN_CrossNet,
     AA_BSA_BISHOP,            // 2012/04/04
     AA_CAB_EEEv1,
     AA_CAF_Hinatarte,
     AA_CycSoft_NNN,
//     AA_DAT_AIL,               // 2011/01/07
     AA_DAT_2XT,               // 2012/03/21
     AA_DAT_CaramelBox,        // 2010/02/02
     AA_DAT_EGO,
     AA_DAT_GoF,
     AA_DAT_JAMCreation,
     AA_DAT_LNK,
     AA_DAT_NEKOPACK,
     AA_DAT_PACKDAT,
     AA_DAT_TaekPack,
     AA_DAT_Touhou,
     AA_DAT_YumeMiruGM,        // 2010/05/28
     AA_DET_NekodePink,        // 2011/02/02
     AA_ELF,
     AA_FJSYS,
     AA_FPAC_OmegaVision,
     AA_FPK_SystemC,
     AA_G_RUNE,
     AA_Gainax_GGEX,
     AA_GPC_SuperNEKO_X,
     AA_GXP_AVGEngineV2,       // 2012/12/02
     AA_HXP_HIMAURI,
     AA_IFL_Arpeggio,          // 2010/12/10
     AA_IKURA_GDL,
//   AA_IMG_Futurama,          // 2011/10/22    to-do: write full implementation
     AA_INI_UnrealEngine3,     // 2010/07/25
     AA_LEAF_AquaPlus,
     AA_LC_ScriptEngine,
     AA_Lib_Malie,
     AA_MBL,
     AA_MRG_ADVWIN32,
     AA_MRG_Overture,          // 2011/06/17
     AA_NEJII,
     AA_NFS_NAGS,
     AA_nScripter,
     AA_PAC_Graduation,
     AA_PAC_Marine,            // 2012/04/04
     AA_PAC_Tech,
     AA_PACK_TroubleWitches,
     AA_PACKED_Scrapland,      // 2013/04/18
     AA_PAK_ADPACK32,
     AA_PAK_DataPack5,
     AA_PAK_EAGLS,
     AA_PAK_IPAC,
     AA_PAK_MTS,
     AA_PAK_NitroPlus,
     AA_PAK_PACK2,
     AA_PAK_PurePure,
     AA_PAK_ScriptPlayer,
     AA_PAK_TScriptEngine,
     AA_PCK_Crowd_Engine_3,
     AA_PD_CrossChannel,
     AA_PKD_Blade_Engine,
     AA_PNI_Xai,               // 2012/03/04
     AA_VPK_Ever17,            // 2012/01/19
     AA_PP_illusion,           // 2010/08/28
     AA_RPA_RenPy,
     AA_RPD_Rejet,             // 2011/05/06
     AA_SOFTPAL,               // 2010/07/02
     AA_SZDD,
     AA_SZS_UnicornA,          // 2011/11/12
     AA_TIM2_ARC,              // 2010/06/09
     AA_TPF_Giga,
     AA_VFS_SystemAoi,         // 2010/08/16
     AA_WAC,
     AA_XFL_Lios,
     AA_XP3_KiriKiri2,
     AA_YKC_Yuka,
     AA_YPF_YURIS,             // 2010/07/30

     AA_IMG_GTA3,
     AA_DAT_MC2;               // 2010/05/07

procedure Init_ArcFormatList;

implementation

uses AnimED_Archives;

procedure Init_ArcFormatList;
begin
 AFAdd(IA_DAT);
 AFAdd(IA_SM2MPX20); // must be before SM2MPX10, otherwise it won't work
 AFAdd(IA_SM2MPX10);
 AFAdd(IA_DRS);
 AFAdd(IA_PD_PackOnly);
 AFAdd(IA_PD_PackPlus);
 AFAdd(IA_PCK_CROWD3);
 AFAdd(IA_ARC_Ethornell_BGI);
 AFAdd(IA_ARC_Will_8);
 AFAdd(IA_ARC_Will_12);         // 2010/12/22
 AFAdd(IA_SAR);
 AFAdd(IA_NSA);
 AFAdd(IA_NS2);                 // 2012/03/01
 AFAdd(IA_NScriptDat);
 AFAdd(IA_PAK_PurePure);
 AFAdd(IA_A_LEAF);
 AFAdd(IA_PAK_LEAF_KCAP);
 AFAdd(IA_PAK_LEAF_LAC);
 AFAdd(IA_PAK_LEAF_LACi);
 AFAdd(IA_MBL1);
 AFAdd(IA_MBL2);
 AFAdd(IA_AFSv2);
 AFAdd(IA_AFSv3);
 AFAdd(IA_AFSv1);
 AFAdd(IA_WAC);
 AFAdd(IA_FPAC); //CAPF
 AFAdd(IA_DAT_PACKDAT);
 AFAdd(IA_DAT_PACKDATe);
 AFAdd(IA_PAK_ADPACK32);
 AFAdd(IA_CAB_EEEv1);
 AFAdd(IA_FJSYS);
 AFAdd(IA_SOFTPAL_BIN);         // 2010/07/02
 AFAdd(IA_SOFTPAL_PAC16);       // 2010/07/02
 AFAdd(IA_SOFTPAL_PAC32);       // 2010/05/21
 AFAdd(IA_SOFTPAL_PAC32_2k10);  // 2011/03/12
 AFAdd(IA_SOFTPAL_059);         // 2010/07/02 
 AFAdd(IA_LCS);
 AFAdd(IA_HXP_HIMAURI_Him4);
 AFAdd(IA_HXP_HIMAURI_Him5);
 AFAdd(IA_GPC_SuperNEKO_X);
 AFAdd(IA_ARC_RPM);
 AFAdd(IA_XP3_KrKr2);
 AFAdd(IA_XP3_KrKr2N);
 AFAdd(IA_XP3_KrKr2N2);
 AFAdd(IA_XP3_KrKr2C);
 AFAdd(IA_XP3_KrKr2NC);
 AFAdd(IA_XP3_KrKr2N2C);
 AFAdd(IA_MRG_ADVWIN32);
 AFAdd(IA_PAK_DataPack5);
 AFAdd(IA_PKD_BladeEngine);
 AFAdd(IA_YKC_Yuka);
 AFAdd(IA_DAT_Nekopackv1);
 AFAdd(IA_PAK_TScriptEnginev3);
 AFAdd(IA_PAK_PACK2);
 AFAdd(IA_ARC_Majiro_v1);
 AFAdd(IA_ARC_Majiro_v2);
 AFAdd(IA_ARC_Majiro_v3);
 AFAdd(IA_G_RUNE);
 AFAdd(IA_Gainax_GCEX);
 AFAdd(IA_PAK_ScriptPlayer);
 AFAdd(IA_ARC_Alcot);
 AFAdd(IA_AOS_Lilim);
 AFAdd(IA_XFL_Lios);
 AFAdd(IA_SZDD);
 AFAdd(IA_AHFS);
 AFAdd(IA_LIB_Malie);
 AFAdd(IA_PAK_EAGLS);
 AFAdd(IA_PAK_EAGLS2011);      // 2011/06/29
 AFAdd(IA_BIN_CrossNet);
 AFAdd(IA_DAT_EGO);
 AFAdd(IA_DAT_EGO_Old);
 AFAdd(IA_PAC_Graduation);
 AFAdd(IA_DAT_GoF);
 AFAdd(IA_FPK_SystemC);
 AFAdd(IA_NEJII);
 AFAdd(IA_CAF_Hinatarte);
 AFAdd(IA_TPF_Giga);
 AFAdd(IA_PAK_IPAC);
 AFAdd(IA_DAT_JAMCreation);
 AFAdd(IA_PACK_TroubleWitches);
 AFAdd(IA_DAT_CaramelBox);
 AFAdd(IA_PAK_MTS);
 AFAdd(IA_EAC_elf);
 AFAdd(IA_AWF_elf);
 AFAdd(IA_ARC_AI6);            // 2011/02/26
 AFAdd(IA_PAK_NitroPlus_Pak1);
 AFAdd(IA_PAK_NitroPlus_Pak2);
 AFAdd(IA_NFS_NAGS);
 AFAdd(IA_PAC_Tech);
 AFAdd(IA_ARC_CRC);
 AFAdd(IA_DAT_YumeMiruGM);
 AFAdd(IA_ARC_KISS);
 AFAdd(IA_TIM2_ARC1);          // 2011/04/18
 AFAdd(IA_TIM2_ARC2);          // 2010/06/09
 AFAdd(IA_BIN_ACPXPK01);       // 2010/06/12
 AFAdd(IA_YPF_YURIS_Auto);     // 2010/08/30
 AFAdd(IA_YPF_YURIS_v222);     // 2010/08/30
 AFAdd(IA_YPF_YURIS_v224);     // 2010/08/30
 AFAdd(IA_YPF_YURIS_v238);     // 2010/08/20
 AFAdd(IA_YPF_YURIS_v247);     // 2010/07/31
 AFAdd(IA_YPF_YURIS_v255);     // 2010/07/31
 AFAdd(IA_YPF_YURIS_v286);     // 2010/09/01
 AFAdd(IA_YPF_YURIS_v287);     // 2010/08/26
 AFAdd(IA_YPF_YURIS_v290_34);  // 2010/07/31
 AFAdd(IA_YPF_YURIS_v290_C0);  // 2010/08/26
 AFAdd(IA_YPF_YURIS_v300);     // 2010/09/05
 AFAdd(IA_YPF_YURIS_v222z);    // 2010/08/30
 AFAdd(IA_YPF_YURIS_v224z);    // 2010/08/30
 AFAdd(IA_YPF_YURIS_v238z);    // 2010/08/20
 AFAdd(IA_YPF_YURIS_v247z);    // 2010/07/31
 AFAdd(IA_YPF_YURIS_v255z);    // 2010/07/31
 AFAdd(IA_YPF_YURIS_v286z);    // 2010/09/01
 AFAdd(IA_YPF_YURIS_v287z);    // 2010/08/26
 AFAdd(IA_YPF_YURIS_v290z_34); // 2010/07/31
 AFAdd(IA_YPF_YURIS_v290z_C0); // 2010/08/26
 AFAdd(IA_YPF_YURIS_v300z);    // 2010/09/05
 AFAdd(IA_VFS_SystemAoi_v2);   // 2010/08/16
 AFAdd(IA_ARC_MikoMai);
 AFAdd(IA_IFL_Arpeggio);       // 2010/12/10
 AFAdd(IA_RPD_Rejet);          // 2011/05/06
 AFAdd(IA_DAT_2XT);            // 2012/03/21

 { Read-only }

 AFAdd(IA_GXP_AVGEv2);         // 2012/12/02

 AFAdd(IA_VPK_Ever17);         // 2012/01/19
 AFAdd(IA_MRG_Overture);       // 2011/06/17
 AFAdd(IA_PP_illusion_JS3);    // 2010/08/28
 AFAdd(IA_SZS_UnicornA);       // 2011/11/12
 AFAdd(IA_PAC_Marine);         // 2012/04/04
 AFAdd(IA_CycSoft_GPK);
 AFAdd(IA_CycSoft_VPK);
 AFAdd(IA_GROOVER_ARC_mode1);
 AFAdd(IA_DAT_Touhou7);
 AFAdd(IA_RPA_RenPy);
// AFAdd(IA_DAT_AIL);            // 2011/01/07
 AFAdd(IA_DET_NekodePink);     // 2011/02/02
 AFAdd(IA_ALD_System4);        // 2011/03/22
 AFAdd(IA_ARC_MAI);            // 2011/04/26
 AFAdd(IA_ARC_DK42007);        // 2011/04/26
 AFAdd(IA_PNI_Xai);            // 2012/03/04
 AFAdd(IA_BSA_BISHOP);         // 2012/04/04

 { Just for fun }
 AFAdd(IA_PACKED_Scrapland);   // 2013/04/18
 AFAdd(IA_INI_UnrealEngine3);  // 2010/07/25
 AFAdd(IA_IMG_GTA3v1);
 AFAdd(IA_IMG_GTA3v2);
 AFAdd(IA_DAT_MC2v1);
 AFAdd(IA_DAT_MC2v2);

 { Read-only just for fun }
// AFAdd(IA_IMG_Futurama);
 AFAdd(IA_DAT_TaekPack);

 { The End }
 AFAdd(IA_Unsupported);
end;

end.