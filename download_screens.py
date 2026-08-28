import os
import json
import urllib.request
import re

screens_data = [
    {
        "id": "15885302ddf04731833010ff300886cb",
        "title": "Mausam - Commute Details",
        "folder": "01_mausam_commute_details",
        "screenshot_url": "https://lh3.googleusercontent.com/aida/AEtjO1XKtFH9qXQb4VpzH0IF5sXbYy1yNSjAcWo5HNOCOIRPLMpkyukPWNkJz3SBC_O5LT_EhHlsin14h0Oht_2mxSbueS57Lrhp5f3vXA30QXSFAiSTxcQgJ4AXRDlkB-hUyKBUD7FC0nXLGhrN78sPTCTTPvKObsSm8ZCxXv9VSSNrJEiFFRIIRHiZ8IHVpw2eDVB1pTpOjLhh_bW-br-eiSpudl_UBA2eSTb6PzCnyCv8epc_FHvJlk17MMnx",
        "html_url": "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzAwMDY1YTFmMzIwNzhjN2IwMmQzZmM3NDNmMjgzZWU5EgsSBxDUv7-1_B0YAZIBJAoKcHJvamVjdF9pZBIWQhQxNzE4NjA0Nzg0NzE2NDI2ODA4OA&filename=&opi=89354086",
        "width": 780,
        "height": 3084,
        "deviceType": "MOBILE"
    },
    {
        "id": "1ac84a0aff014d7bb267db2fe84d48aa",
        "title": "Mausam - Fitness Details",
        "folder": "02_mausam_fitness_details",
        "screenshot_url": "https://lh3.googleusercontent.com/aida/AEtjO1WRxShOM8IZS1FikMcnGTmlgUygbG7v2-STDkxDmWxObtRK_KBNwMfBkEeVfJL6tbUH6DmbmCXko4cojxhH0Udl_WfLTOY8Ig3qqceXGlhkUIGe6v87LHV5991JKsmlswtyfHeT_tXXu1wtTy-e0Sgmp2PNH4Sp0XdxO4BQUVLhmRHu-RB_HUi8g8vEalk5hso19eGr-yKQJozTVLwvViejsKbZNDwnt0gCdJ5B35VWZIO74l01lICO2MIb",
        "html_url": "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzAwMDY1YTFmMjg4YjY4MWQwNDczNmMxNDRkMTI4YTcwEgsSBxDUv7-1_B0YAZIBJAoKcHJvamVjdF9pZBIWQhQxNzE4NjA0Nzg0NzE2NDI2ODA4OA&filename=&opi=89354086",
        "width": 780,
        "height": 2476,
        "deviceType": "MOBILE"
    },
    {
        "id": "27fde76bfc7e41b1bcd7c103933ff06b",
        "title": "Mausam - Travel Details",
        "folder": "03_mausam_travel_details",
        "screenshot_url": "https://lh3.googleusercontent.com/aida/AEtjO1VMP5oZ4QWCwDG_WXTUm00NQ54FGiC_4_yEvQwj7HJPGBnZhzU2gzpxTVUy3opRuQV0dA6kEPv-ZGnjdUrBepmnY6R4Q09u1xKNsRI5mZsr3AODhKNOq_ASGN3utOLpPQPTUOkiGarT0WtJbkRcwZViUatdunY0NZ27J_9PjjzcLxUhA9m8BO-zZdzehixT_iBp7BEVQZL3rVwfsZzwB5cssgr2TfqFxnKCdK7wHH9YIa2F8qr1oNOY5ITp",
        "html_url": "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzAwMDY1YTFmMmMzMWE0MzMwMzgzYTcxNGRhMWZjNTlmEgsSBxDUv7-1_B0YAZIBJAoKcHJvamVjdF9pZBIWQhQxNzE4NjA0Nzg0NzE2NDI2ODA4OA&filename=&opi=89354086",
        "width": 780,
        "height": 2270,
        "deviceType": "MOBILE"
    },
    {
        "id": "33fee670f22748438b42f2b626ef214a",
        "title": "Mausam - Health Details",
        "folder": "04_mausam_health_details",
        "screenshot_url": "https://lh3.googleusercontent.com/aida/AEtjO1UsegI_5zd0VjlNBJ-uvz5m95i0yfj2-5QaT4OoagFcWkFFkDnFlhexCCcr1zEs9xt2nTDKLMurg_1kTl9K4QEbbJd61LTlGXqCf1lklBWw2Tmqfi1lznk9CLC0naRtZHTT_ji2ejHbtZbQI6yCmpWXxB4YOd3awhaCJFVMjqYfF5coppsgfGQ585XuZfytZwzftV4dAyVrnBy7Es8Xj1g7w2ToeJXezpGupeAtX9JKPWRcdHV1QD3Ui768",
        "html_url": "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzAwMDY1YTFmMjhiZjM1YzMwMzM4NTg1NjFmM2FlOWQwEgsSBxDUv7-1_B0YAZIBJAoKcHJvamVjdF9pZBIWQhQxNzE4NjA0Nzg0NzE2NDI2ODA4OA&filename=&opi=89354086",
        "width": 780,
        "height": 2512,
        "deviceType": "MOBILE"
    },
    {
        "id": "5230c904240c4318b1f9b543045479ee",
        "title": "Mausam - Family Details",
        "folder": "05_mausam_family_details",
        "screenshot_url": "https://lh3.googleusercontent.com/aida/AEtjO1WKLFE1SH_CzcAeOgxjucBgmcwGx3sJd9amPdZUQQogkxChbe7_cf8j7cyg1t4e-p-bTNGxEzAbsy87YzzT6941PlEX3_cV4zKXrACZYH85ar_ycWeaRRxfmU0Zxc3VmjboRKbV-1CgDdLM_1iYlIXXuCHuZmiN6oE3jGY8e5wFRn0eiXMTPmdBZECxapVO7dN6gZ10fwWTgLXK_-yredyPFu-47uZqmcoQexadOwDeEYg346m2aUfZZ22S",
        "html_url": "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzAwMDY1YTFmMzZmZWQyZWEwNzNhZDYwYmIxMmMyZjVlEgsSBxDUv7-1_B0YAZIBJAoKcHJvamVjdF9pZBIWQhQxNzE4NjA0Nzg0NzE2NDI2ODA4OA&filename=&opi=89354086",
        "width": 780,
        "height": 2612,
        "deviceType": "MOBILE"
    },
    {
        "id": "5896ca63cad44505a002e9a818159c7d",
        "title": "Mausam Home - Marine Active",
        "folder": "06_mausam_home_marine_active",
        "screenshot_url": "https://lh3.googleusercontent.com/aida/AEtjO1UYCIZD3hroYpkwR6IO3SYnmbx2OVpyWCo7Fv1goCzRgMwt1GQnzHVQpMdwjV-C7SZD3cNGSmTy91bHKop_k9sxzERz0ERbfe2VMAdddUkyARfAe034f9cXj91eZ9TCpMoaUwwbg2uiJGHK5e7mJWyV4sca1OjizXHvhYqXSP3mv2n28_GWVHBw6fSKp-tmkdNn5HSAeXWvlCDzjJAKK7itGMA9EQz1FahY8uzxpSlhMP4IMiZz1SYrjxsP",
        "html_url": "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzAwMDY1YTFmNDFlMzM3Y2YwOTI1ZDRhNmVhMGIwMjQ2EgsSBxDUv7-1_B0YAZIBJAoKcHJvamVjdF9pZBIWQhQxNzE4NjA0Nzg0NzE2NDI2ODA4OA&filename=&opi=89354086",
        "width": 780,
        "height": 1768,
        "deviceType": "MOBILE"
    },
    {
        "id": "6b31fb9e5a554ebe924a45da4f0e9e0f",
        "title": "Mausam - Event Planner Details",
        "folder": "07_mausam_event_planner_details",
        "screenshot_url": "https://lh3.googleusercontent.com/aida/AEtjO1XTY3RRGpk9wyV8wFI7aYIcDCVyJ4UgMG2L6NQKbSYCdMlEWpf6jKcwE7TdNh-6ht26ppZglBhsh1r763H34YGi13jT_WnR0r_zQAWsUSOT2MXgi0fuX0QULqEPDJ8a-DCRybRBEJ03bpXl3WdkvP0BW-YRl-O56tmbzpTbM-mnUv0mWQppzv1NHLkPTopFJphIDACwsQGbI6_Pk8M6n7cvIFmKg6W-fjNu2phdg4x0Rgpm1rn3lDDmE-o0",
        "html_url": "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzAwMDY1YTFmM2E5YmNlOWEwMzgzOWM4Mjc1M2M0NTAxEgsSBxDUv7-1_B0YAZIBJAoKcHJvamVjdF9pZBIWQhQxNzE4NjA0Nzg0NzE2NDI2ODA4OA&filename=&opi=89354086",
        "width": 780,
        "height": 2618,
        "deviceType": "MOBILE"
    },
    {
        "id": "8253a3e8e5244260bd672a9069cd0794",
        "title": "Mausam - Customize Homepage",
        "folder": "08_mausam_customize_homepage",
        "screenshot_url": "https://lh3.googleusercontent.com/aida/AEtjO1Wm2TYnblZTeQhf5gzUGdq2cTDgkaH0KQlF4S8VcwBs9tAVMEfwTgmj6yuW47SZd_8KD3pMLNBeKL-LsDVNyMmRDIFBfZZR_p5ES43i0yJcmlmbTumdWNXG53Bp80WURu9Lt17upYwx7e8rmcbHUbTLaXxhgRJjsb1aCSQhEmbWRRiscZYNcoGqMMuKkc7wbphCrSDD1FA-lYLyldvdoTw1Rt8OnJvtsJ1CXiWDMBpSNiU1phnitMKqH1w",
        "html_url": "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzAwMDY1YTFmMWE0MWUxN2MwNTc2MDFlN2U1MGUxNjI1EgsSBxDUv7-1_B0YAZIBJAoKcHJvamVjdF9pZBIWQhQxNzE4NjA0Nzg0NzE2NDI2ODA4OA&filename=&opi=89354086",
        "width": 780,
        "height": 1768,
        "deviceType": "MOBILE"
    },
    {
        "id": "908fa43ea7e94caebf7073a37380665e",
        "title": "Mausam Home - Default",
        "folder": "09_mausam_home_default",
        "screenshot_url": "https://lh3.googleusercontent.com/aida/AEtjO1WBYEAFJiM4sB3Utb-Mb4Gs0HQRViMAdKqm2MIm80svgFEXQHgJUVYRlUEjtiIfwyYkTJ7qjqL58vKSLzUXyJ68u_GJmjlyRWYw_QZR-wzv4G3ssGKJVtuXcRyEFh5Bs0kSc-BrVh7-7NrjKdlAKKnRh_QfM_xO-ETXEzxxp7G5IfH1GH-OrCHVKvmPPq2nyCyElyjMx7MQmSzTPeE35yUGeyN8hU-Gj_5SxBHxaG369KA69FRX8P56da2z",
        "html_url": "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzAwMDY1YTFmMTk5NDU4MjEwMjhmMGMzMWQ3MmE2MmRhEgsSBxDUv7-1_B0YAZIBJAoKcHJvamVjdF9pZBIWQhQxNzE4NjA0Nzg0NzE2NDI2ODA4OA&filename=&opi=89354086",
        "width": 780,
        "height": 1768,
        "deviceType": "MOBILE"
    },
    {
        "id": "911d3589e2e4465c93ab3dc652e43a42",
        "title": "Mausam - Marine Details - Tide Priority",
        "folder": "10_mausam_marine_details_tide_priority",
        "screenshot_url": "https://lh3.googleusercontent.com/aida/AEtjO1WyTczQ1B0IR6DMZ2EiI-B1uA-dfCl4F9dY3hzPf7LzXX8VBThyebPQl1nGivZSwOiizav5sTpFOUTu1gZ8VNoKEYxXrdhbWGueS6EHUMwS3wF-npiWn-cDdputG_y3fhVfMAe013tGfJMWp5Ew-t5eoCDhs3T46OVsditFsze4HgsFyaXldsbRnbSsIMsvWcstC7TggXxyFeJeLxr3sEjLA4OOr3WeIVOXgu0J6L7m2nltnPGfOS1OedC-",
        "html_url": "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzAwMDY1YTFmNTg2NWI3NjYwMWI0ZTQ0Yzg5MzUzYzI0EgsSBxDUv7-1_B0YAZIBJAoKcHJvamVjdF9pZBIWQhQxNzE4NjA0Nzg0NzE2NDI2ODA4OA&filename=&opi=89354086",
        "width": 780,
        "height": 2108,
        "deviceType": "MOBILE"
    },
    {
        "id": "c184bbdf1b044e5fa4ca0800bdf332ac",
        "title": "Mausam Onboarding - Personas",
        "folder": "12_mausam_onboarding_personas",
        "screenshot_url": "https://lh3.googleusercontent.com/aida/AEtjO1XAKGD2p0UTWCNstW2xrAXKkyDLVeYyUyf85w7tRHK9GQidTedf15QPsbR0NGclkSuXzpnoTIbmZ7-tgfHyKcS7UQjOdBU5-XxvULKvJOt5vglua7R-DKvO9nLZDW9Kj-gDtteCGLs_d8KCgCj2yUZVmVoEVR9dp7610DJvcbX8cDACUW3oQaJNbSWvm-vymY23o6PBhwA8L_E6fsDZYY74DFYMCidEx_rwtMSft5sxEhZqcYK38PWtP_0h",
        "html_url": "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzAwMDY1YTFmMTk3ZmQ0ZjYwN2M0ZTJkYjY5MDlhNzA1EgsSBxDUv7-1_B0YAZIBJAoKcHJvamVjdF9pZBIWQhQxNzE4NjA0Nzg0NzE2NDI2ODA4OA&filename=&opi=89354086",
        "width": 780,
        "height": 1902,
        "deviceType": "MOBILE"
    },
    {
        "id": "ccebb3545faa45b5823893c2215eb897",
        "title": "Mausam Home - Alert Active",
        "folder": "13_mausam_home_alert_active",
        "screenshot_url": "https://lh3.googleusercontent.com/aida/AEtjO1VCF56NZ3zW8w0vCZfywLrfaPnt4MTkHONpNWHG6JGHWWuPXQsdIIrDEauyAiHW0QLQfecGq5ZPV8lxHi51h95fJfH3h4xgmCbwsfDBvsgR2BhN0oeNewMvwewBOBjnXY-3z5ztYI-PIzk1k7gncElFbTmL0PSy1mFTSl6bSRmWswnopUFNZrq5onp0GIGe0s5PsainLStTORq-NDv06YkPQErXG_mws9PHa_zb3MaHxGFpsEE61xWg5DRX",
        "html_url": "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzAwMDY1YTFmMWE5MjEyNjgwMjJkNGZhOTIyMGQ4YWVhEgsSBxDUv7-1_B0YAZIBJAoKcHJvamVjdF9pZBIWQhQxNzE4NjA0Nzg0NzE2NDI2ODA4OA&filename=&opi=89354086",
        "width": 780,
        "height": 1768,
        "deviceType": "MOBILE"
    },
    {
        "id": "ddd5dd60a4e344eead80fbb90b410868",
        "title": "Mausam - Agriculture Details - Soil Moisture Priority",
        "folder": "14_mausam_agriculture_details_soil_moisture_priority",
        "screenshot_url": "https://lh3.googleusercontent.com/aida/AEtjO1XVqPzT_2Ynjslmk6DRGv64xV_lAwNn7VZWW6t8fVYL9XIf7hHGTvASSf7HCbNy5ymXf3lITVDcrOpxxVnRHnkLm7RxdCW_83J3kZ_mqt9GlcLF3DmeaJkq_w2qcAIk7JsmX-inR-GjQYv4b8Yt9P_uRLss6lFgr-sxDsLjMKzu1_WK0iFgRMHGNxHSwfF4EYSv2qFUvgWPYo6KnxShfV3my5VZQ6nOulJ5wa8-TlBmH4ILfN_zDF5bgFxM",
        "html_url": "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzAwMDY1YTFmNTYwOTRiNzYwNzc5ODRmNGMxMmM0NjA4EgsSBxDUv7-1_B0YAZIBJAoKcHJvamVjdF9pZBIWQhQxNzE4NjA0Nzg0NzE2NDI2ODA4OA&filename=&opi=89354086",
        "width": 780,
        "height": 1996,
        "deviceType": "MOBILE"
    },
    {
        "id": "f887f6b8687c4c8ca287fb2f05f9f11f",
        "title": "Mausam - Agriculture Details",
        "folder": "15_mausam_agriculture_details",
        "screenshot_url": "https://lh3.googleusercontent.com/aida/AEtjO1UXi7T1rDmOBzv2xGPp3j9TwJ0HhHP2ry_g2VvT2lozwEtYgpAV58TrO0k8SGOEJKkMqo5rEr9xdCO8RLnYJdxtolKwGtJ34Q5tj3ctMrjhoaL1NPInWoYgV_vFbOsUTQYm3PTu58TB8od7GKnq3steq_KqcNdCa-4hW2y4-OFBAPyRJiME2DS0E91UlfiwNeDSnAf4ZuK5mlpkbI1eE7m0zT0mlGtyd79SFYpc647i4O6FfzLhFFjbQg3i",
        "html_url": "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzAwMDY1YTFmMjIyY2E5MTIwN2M0ZTJkYjY5MDlhNzA1EgsSBxDUv7-1_B0YAZIBJAoKcHJvamVjdF9pZBIWQhQxNzE4NjA0Nzg0NzE2NDI2ODA4OA&filename=&opi=89354086",
        "width": 780,
        "height": 1996,
        "deviceType": "MOBILE"
    },
    {
        "id": "f8ac92f62a824033a29eebff0ed529dd",
        "title": "Mausam - Marine Details",
        "folder": "16_mausam_marine_details",
        "screenshot_url": "https://lh3.googleusercontent.com/aida/AEtjO1VH_n25whSsj9pR9pUh_pi9HiX_aM4jEmiD0olVNZsQ78gHe5jxDln0A8ngAlU2om5DaY4blZLBFs9ihdTtg27-1i17NZbWHc4RvFp4V7q-dglUwVAIPMMw2Vuk16p_EnXrfNOUcuxgQOSZK-7o-hkDzE2q2nBgIhA9SVnFYOfdIVzBb8-3PhBfD2eNKCUdhQ6YFKw_gfaK41HjuJbI-42tt2KZb39PBKVwjm9TCPPBSmVWusDvSAG4QDA",
        "html_url": "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzAwMDY1YTFmNDZiZmQwODMwN2M0YzE1ZWNmMGFlYzMwEgsSBxDUv7-1_B0YAZIBJAoKcHJvamVjdF9pZBIWQhQxNzE4NjA0Nzg0NzE2NDI2ODA4OA&filename=&opi=89354086",
        "width": 780,
        "height": 2084,
        "deviceType": "MOBILE"
    }
]

design_system_info = {
    "id": "asset-stub-assets_edc91637919748af8fab09437f918ce8",
    "name": "assets/edc91637919748af8fab09437f918ce8",
    "displayName": "Mausam Precision",
    "styleGuidelines": """## Brand & Style

The design system is engineered for the India Meteorological Department (IMD) to provide authoritative, life-saving weather data with absolute clarity. The brand personality is **Institutional, Vigilant, and Accessible**. It balances the gravity of government-grade reporting with the modern efficiency of a high-performance utility.

The visual style is **Corporate Modern** with a focus on high-density information architecture. It utilizes a structured hierarchy where data is prioritized through modularity. The emotional response is one of trust and reliability, ensuring users—from rural farmers to urban commuters—can interpret complex meteorological shifts at a glance.

## Layout & Spacing

This design system employs a **Fluid Grid** model optimized for mobile-first consumption. 

- **Grid Model:** A 4-column grid for mobile, scaling to 8-columns for tablets. 
- **Rhythm:** An 8px base unit governs all spatial relationships. 
- **Safe Zones:** A 20px horizontal margin ensures content does not touch device edges. 
- **Modularity:** Content is organized into "Widgets" that occupy 100% or 50% of the available width, allowing for a flexible, dashboard-like reflow on larger screens.

## Elevation & Depth

Depth is used sparingly to maintain a clean, professional appearance. 

- **Tonal Layers:** The primary background is `#F5F5F5`. Elevated content sits on Pure White cards.
- **Shadows:** Use extra-diffused, low-opacity shadows (e.g., `box-shadow: 0 4px 12px rgba(26, 35, 126, 0.08)`) to create soft separation without adding visual weight.
- **Interactive States:** Buttons and cards use a subtle "lift" effect (increased shadow) when active, providing tactile feedback for touch interactions.

## Components

- **Buttons:** Primary buttons use the Deep IMD Blue with white text. Floating Action Buttons (FABs) for "Report Weather" use the Marine Blue.
- **Weather Cards:** Large-format cards (24px radius) containing current conditions. Secondary cards for 7-day forecasts should use a 16px radius.
- **Alert Chips:** High-contrast status indicators. Severe weather alerts use `Warning Orange` backgrounds with black text for maximum visibility.
- **Input Fields:** Outlined style with 1px borders in a soft neutral grey. On focus, the border transitions to Deep IMD Blue.
- **Data Widgets:** Modular units containing a line-icon, a label, and a data point (e.g., "Visibility | 5km").
- **Iconography:** Thin-to-medium weight line icons. Use `Marine Blue` for standard weather icons and `Warning Orange` for hazardous weather icons.""",
    "designMd": """---
name: Mausam Precision
colors:
  surface: '#f9f9f9'
  surface-dim: '#dadada'
  surface-bright: '#f9f9f9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f3'
  surface-container: '#eeeeee'
  surface-container-high: '#e8e8e8'
  surface-container-highest: '#e2e2e2'
  on-surface: '#1a1c1c'
  on-surface-variant: '#454652'
  inverse-surface: '#2f3131'
  inverse-on-surface: '#f1f1f1'
  outline: '#767683'
  outline-variant: '#c6c5d4'
  surface-tint: '#4c56af'
  primary: '#000666'
  on-primary: '#ffffff'
  primary-container: '#1a237e'
  on-primary-container: '#8690ee'
  inverse-primary: '#bdc2ff'
  secondary: '#00639a'
  on-secondary: '#ffffff'
  secondary-container: '#51b2fe'
  on-secondary-container: '#00436a'
  tertiary: '#002104'
  on-tertiary: '#ffffff'
  tertiary-container: '#00390a'
  on-tertiary-container: '#48ab4d'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e0e0ff'
  primary-fixed-dim: '#bdc2ff'
  on-primary-fixed: '#000767'
  on-primary-fixed-variant: '#343d96'
  secondary-fixed: '#cee5ff'
  secondary-fixed-dim: '#96ccff'
  on-secondary-fixed: '#001d32'
  on-secondary-fixed-variant: '#004a75'
  tertiary-fixed: '#94f990'
  tertiary-fixed-dim: '#78dc77'
  on-tertiary-fixed: '#002204'
  on-tertiary-fixed-variant: '#005313'
  background: '#f9f9f9'
  on-background: '#1a1c1c'
  surface-variant: '#e2e2e2'
typography:
  display-temp:
    fontFamily: Inter
    fontSize: 64px
    fontWeight: '700'
    lineHeight: 72px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
  data-mono:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: -0.01em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-margin: 20px
  widget-gap: 12px
  internal-padding: 16px
---

## Brand & Style

The design system is engineered for the India Meteorological Department (IMD) to provide authoritative, life-saving weather data with absolute clarity. The brand personality is **Institutional, Vigilant, and Accessible**. It balances the gravity of government-grade reporting with the modern efficiency of a high-performance utility.

The visual style is **Corporate Modern** with a focus on high-density information architecture. It utilizes a structured hierarchy where data is prioritized through modularity. The emotional response is one of trust and reliability, ensuring users—from rural farmers to urban commuters—can interpret complex meteorological shifts at a glance.

## Colors

The palette is anchored by **Deep IMD Blue**, signaling authority and the vastness of the atmosphere. 

- **Primary (#1A237E):** Reserved for headers, primary actions, and institutional branding.
- **Marine Blue (#0288D1):** Used for interactive elements, links, and water-related data visualizations.
- **Functional Accents:** Success Green, Warning Orange, and Caution Yellow are used strictly for status-driven data (e.g., severe weather alerts, air quality indices).
- **Surface:** A Pure White base is used for maximum contrast, supported by a light neutral grey for background layering and secondary card containers.

## Typography

This design system utilizes **Inter** for its exceptional legibility and neutral, systematic tone. The type scale is optimized for high-density data legibility across a wide age demographic.

- **Numerical Priority:** Large temperature readings use `display-temp` with slight negative letter-spacing to ensure the primary data point is unavoidable.
- **Clarity:** Use `body-lg` for critical weather descriptions and `label-caps` for secondary data categories (e.g., "HUMIDITY", "WIND SPEED").
- **Accessibility:** Line heights are generous to prevent visual crowding in data-heavy widgets.

## Layout & Spacing

This design system employs a **Fluid Grid** model optimized for mobile-first consumption. 

- **Grid Model:** A 4-column grid for mobile, scaling to 8-columns for tablets. 
- **Rhythm:** An 8px base unit governs all spatial relationships. 
- **Safe Zones:** A 20px horizontal margin ensures content does not touch device edges. 
- **Modularity:** Content is organized into "Widgets" that occupy 100% or 50% of the available width, allowing for a flexible, dashboard-like reflow on larger screens.

## Elevation & Depth

Depth is used sparingly to maintain a clean, professional appearance. 

- **Tonal Layers:** The primary background is `#F5F5F5`. Elevated content sits on Pure White cards.
- **Shadows:** Use extra-diffused, low-opacity shadows (e.g., `box-shadow: 0 4px 12px rgba(26, 35, 126, 0.08)`) to create soft separation without adding visual weight.
- **Interactive States:** Buttons and cards use a subtle "lift" effect (increased shadow) when active, providing tactile feedback for touch interactions.

## Shapes

The shape language is defined by **Rounded (0.5rem / 8px)** corners for standard UI components like buttons and inputs. 

- **Cards:** For modular data widgets, use `rounded-lg` (16px) or `rounded-xl` (24px) to soften the information-heavy layout and create a modern, friendly container feel.
- **Consistency:** All stroke-based icons should use rounded terminals to match the container geometry.

## Components

- **Buttons:** Primary buttons use the Deep IMD Blue with white text. Floating Action Buttons (FABs) for "Report Weather" use the Marine Blue.
- **Weather Cards:** Large-format cards (24px radius) containing current conditions. Secondary cards for 7-day forecasts should use a 16px radius.
- **Alert Chips:** High-contrast status indicators. Severe weather alerts use `Warning Orange` backgrounds with black text for maximum visibility.
- **Input Fields:** Outlined style with 1px borders in a soft neutral grey. On focus, the border transitions to Deep IMD Blue.
- **Data Widgets:** Modular units containing a line-icon, a label, and a data point (e.g., "Visibility | 5km").
- **Iconography:** Thin-to-medium weight line icons. Use `Marine Blue` for standard weather icons and `Warning Orange` for hazardous weather icons."""
}

def download_file(url, dest_path):
    req = urllib.request.Request(
        url,
        headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}
    )
    with urllib.request.urlopen(req) as resp:
        content = resp.read()
        with open(dest_path, "wb") as f:
            f.write(content)
        return len(content)

base_dir = os.path.dirname(os.path.abspath(__file__))
screens_dir = os.path.join(base_dir, "screens")
design_dir = os.path.join(base_dir, "design_system")

os.makedirs(screens_dir, exist_ok=True)
os.makedirs(design_dir, exist_ok=True)

# Save design system
with open(os.path.join(design_dir, "design-system.json"), "w", encoding="utf-8") as f:
    json.dump(design_system_info, f, indent=2)

with open(os.path.join(design_dir, "DESIGN.md"), "w", encoding="utf-8") as f:
    f.write(design_system_info["designMd"])

print(f"Saved design system to {design_dir}")

# Download screens
results = []
for idx, s in enumerate(screens_data, 1):
    screen_folder = os.path.join(screens_dir, s["folder"])
    os.makedirs(screen_folder, exist_ok=True)
    
    # Screenshot
    ss_path = os.path.join(screen_folder, "screenshot.png")
    ss_size = download_file(s["screenshot_url"], ss_path)
    
    # HTML Code
    html_path = os.path.join(screen_folder, "index.html")
    html_size = download_file(s["html_url"], html_path)
    
    # Metadata json
    meta_path = os.path.join(screen_folder, "meta.json")
    with open(meta_path, "w", encoding="utf-8") as f:
        json.dump(s, f, indent=2)
        
    print(f"[{idx}/{len(screens_data)}] {s['title']} -> Screenshot: {ss_size:,} bytes | HTML: {html_size:,} bytes")
    results.append({
        "title": s["title"],
        "id": s["id"],
        "folder": s["folder"],
        "screenshot_size": ss_size,
        "html_size": html_size
    })

print("\nAll downloads completed successfully!")
