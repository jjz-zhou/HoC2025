
Election results retrieved from [NHK website](https://www.nhk.or.jp/senkyo/database/sangiin/2025/kaihyomap/).

## Variable Descriptions

| Variable Name     | Description |
|------------------|-------------|
| `senkId`         | Unique identifier for electoral districts (n=45). Electoral district boundaries are drawn based on prefectures with the exception of the Tottori-Shimane and Ehime-Kochi districts. |
| `senkNm`         | Electoral district name in kanji. |
| `pref_turnout`   | Voter turnout (%) at the prefectural level. |
| `pref_votes`     | Votes cast for candidate in the prefecture. |
| `pref_voteShare` | Vote share (%) for candidate in the prefecture. |
| `khId`           | Unique identifier for the candidate (character class). |
| `name_kanji`     | Candidate's name in kanji. |
| `name_kana`      | Candidate's name in kana. |
| `partyId`        | Unique identifier for the candidate's political party. |
| `cand_incumbent` | Candidate incumbency (現,元,新) |
| `partyNm_short`  | Short name of the political party. |
| `partyNm`        | Full name of the political party. |
| `elected`        | Election outcome (1 = elected, 0 = not elected). |
| `muncode`        | Municipality identifier (character class) |
| `mun_name`       | Name of the municipality. |
| `mun_turnout`    | Voter turnout (%) at the municipal level. |
| `votes`          | Number of votes the candidate received in the municipality. |
| `mun_voteShare`  | Vote share (%) for the candidate in the municipality. |

## Notes

- 1892 (out of 1894) municipalities can be identified with `muncode` ([eStat municipality identifier](https://www.e-stat.go.jp/municipalities/cities/areacode)). The remaining two municipalities are "薩摩川内市１" and "薩摩川内市２", coded "NA" under `muncode`.
- July 25, 2025: `pref_votes` description edited; previously noted as total valid votes cast.
