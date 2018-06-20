---
params:
 title: "FlipTheFleet Test Black Box Data: Codebook"
 subtitle: "Exploration of test data"
title: 'FlipTheFleet Test Black Box Data: Codebook'
subtitle: 'Exploration of test data'
author: 'Ben Anderson (b.anderson@soton.ac.uk, `@dataknut`)'
date: 'Last run at: 2018-06-20 13:48:41'
# output:
#   html_document:
#     code_folding: hide
#     fig_caption: true
#     keep_md: true
#     number_sections: true
#     self_contained: no
#     toc: true
#     toc_float: true
#     toc_depth: 2
#   pdf_document:
#     fig_caption: yes
#     keep_tex: yes
#     number_sections: yes
#     toc: yes
#     toc_depth: 2
# bibliography: '/Users/ben/bibliography.bib'
output:
  bookdown::html_document2:
    toc: true
    toc_float: TRUE
    toc_depth: 2
    keep_md: TRUE
    self_contained: no
  bookdown::pdf_document2:
    toc: true
    toc_depth: 2
bibliography: '/Users/ben/git.soton/ba1e12/nzGREENGrid/bibliography.bib'
---





\newpage

# Citation

If you wish to use any of the material from this report please cite as:

 * Anderson, B. (2018) FlipTheFleet Test Black Box Data: Codebook: Exploration of test data, [Centre for Sustainability](http://www.otago.ac.nz/centre-sustainability/), University of Otago: Dunedin.

This work is (c) 2018 the University of Southampton.

\newpage

# About

## Circulation


Report circulation:

 * Restricted to: [NZ GREEN Grid](https://www.otago.ac.nz/centre-sustainability/research/energy/otago050285.html) project partners and contractors.
 
## Purpose

This report is intended to: 

 * load and test preliminary 'black box' EV monitoring data provided for assessment purposes by [FlipTheFleet](http://flipthefleet.org/).

## Requirements:

 * test dataset stored at /Volumes/hum-csafe/Research Projects/GREEN Grid/_RAW DATA/flipTheFleet/

## History


Generally tracked via our git.soton [repo](https://git.soton.ac.uk/ba1e12/nzGREENGrid):

 * [history](https://git.soton.ac.uk/ba1e12/nzGREENGrid/commits/master)
 * [issues](https://git.soton.ac.uk/ba1e12/nzGREENGrid/issues)
 
Specific history of this code:

 * https://git.soton.ac.uk/ba1e12/nzGREENGrid/tree/master/analysis/ev

## Support


This work was supported by:

 * The [University of Otago](https://www.otago.ac.nz/);
 * The [University of Southampton](https://www.southampton.ac.uk/);
 * The New Zealand [Ministry of Business, Innovation and Employment (MBIE)](http://www.mbie.govt.nz/) through the [NZ GREEN Grid](https://www.otago.ac.nz/centre-sustainability/research/energy/otago050285.html) project;
 * [SPATIALEC](http://www.energy.soton.ac.uk/tag/spatialec/) - a [Marie Skłodowska-Curie Global Fellowship](http://ec.europa.eu/research/mariecurieactions/about-msca/actions/if/index_en.htm) based at the University of Otago’s [Centre for Sustainability](http://www.otago.ac.nz/centre-sustainability/staff/otago673896.html) (2017-2019) & the University of Southampton's Sustainable Energy Research Group (2019-202).

We do not 'support' the code but if you have a problem check the [issues](https://git.soton.ac.uk/ba1e12/nzGREENGrid/issues) on our [repo](https://git.soton.ac.uk/ba1e12/nzGREENGrid) and if it doesn't already exist, open one. We might be able to fix it :-)
 

# Load data files

## EV test data



In this section we load and describe the  data files from /Volumes/hum-csafe/Research Projects/GREEN Grid/_RAW DATA/flipTheFleet/EVBlackBox export 2018-06-10-233146.csv. Note that we remove the following variables before we do so as they are potentially disclosive:

 * `Reg No`
 * `Latitude`
 * `Longitude` 
 * `Course (deg)` 


```
## Parsed with column specification:
## cols(
##   .default = col_integer(),
##   `Reg No` = col_character(),
##   `Date (GPS)` = col_character(),
##   `Time (GPS)` = col_time(format = ""),
##   Latitude = col_double(),
##   Longitude = col_double(),
##   Altitude = col_double(),
##   `Speed (GPS)` = col_double(),
##   `Speed (Speedometer)` = col_double(),
##   `Course (deg)` = col_double(),
##   SOC = col_double(),
##   AHr = col_double(),
##   `Pack volts` = col_double(),
##   `Pack amps` = col_double(),
##   `Pack 1 temp (C)` = col_double(),
##   `Pack 2 temp (C)` = col_double(),
##   `Pack 3 temp (C)` = col_double(),
##   `Pack 4 temp (C)` = col_double(),
##   `12V battery (amps)` = col_double(),
##   Hx = col_double(),
##   VIN = col_character()
##   # ... with 16 more columns
## )
```

```
## See spec(...) for full column specifications.
```

Create some useful derived variables.

```r
# create dateTime var
ftfSafeDT <- ftfSafeDT[, rDate := lubridate::dmy(`Date (GPS)`)]
ftfSafeDT <- ftfSafeDT[, rTime := hms::parse_hms(`Time (GPS)`)]
#ftfSafeDT <- ftfSafeDT[, dateTime := lubridate::dmy_hms(rDate, rTime)]
```

Describe using skim:


```
## Skim summary statistics
##  n obs: 12487 
##  n variables: 142 
## 
## ── Variable type:character ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────
##    variable missing complete     n min max empty n_unique
##  Date (GPS)    1160    11327 12487  10  10     0       39
##         VIN     163    12324 12487  10  16     0        2
## 
## ── Variable type:Date ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
##  variable missing complete     n        min        max     median n_unique
##     rDate    1160    11327 12487 2018-05-01 2018-06-11 2018-05-18       39
## 
## ── Variable type:difftime ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────
##    variable missing complete     n     min        max   median n_unique
##       rTime    1160    11327 12487 36 secs 86391 secs 03:46:32     8903
##  Time (GPS)    1160    11327 12487 36 secs 86391 secs 03:46:32     8903
## 
## ── Variable type:integer ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
##                 variable missing complete     n     mean       sd     p0
##              avg_cp (mV)     138    12349 12487  4441.28  4078.58   2811
##                     cp_1     138    12349 12487  3174.82  2372.61  -4110
##                    cp_10     138    12349 12487  3980.26  3862.48 -64784
##                    cp_11     138    12349 12487  3658.69  4343.36 -64014
##                    cp_12     138    12349 12487  4026.2   4036.14 -65039
##                    cp_13     139    12348 12487  3632.37  4378.55 -63503
##                    cp_14     139    12348 12487  3618.7   4323.64 -64783
##                    cp_15     139    12348 12487  3228.86  4615.84 -64527
##                    cp_16     139    12348 12487  3572.19  4383.25 -64782
##                    cp_17     139    12348 12487  3872.05  4087.45 -63246
##                    cp_18     139    12348 12487  3947.86  4035.15 -50703
##                    cp_19     139    12348 12487  3865.68  4100.5  -64526
##                     cp_2     138    12349 12487  3584.68  1702.91  -4112
##                    cp_20     139    12348 12487  3946.56  3997.24 -46095
##                    cp_21     139    12348 12487  4124.23  3864.29 -49423
##                    cp_22     139    12348 12487  4118.77  3898.07 -49423
##                    cp_23     139    12348 12487  4116.85  3925.22 -51471
##                    cp_24     139    12348 12487  4070.32  3975.32 -64527
##                    cp_25     139    12348 12487  4081.52  3934.05  -4108
##                    cp_26     139    12348 12487  4025.31  4006.23 -56591
##                    cp_27     139    12348 12487  4018.76  3940.31 -56591
##                    cp_28     139    12348 12487  4074.24  3940.73  -4103
##                    cp_29     139    12348 12487  3784.94  4249.21 -64526
##                     cp_3     138    12349 12487  3387.44  4785.94 -50785
##                    cp_30     139    12348 12487  4033.57  3980.33 -64782
##                    cp_31     139    12348 12487  4056.02  4060.01 -46094
##                    cp_32     139    12348 12487  4041.84  4011.13 -49679
##                    cp_33     139    12348 12487  4105.48  4113.93 -63502
##                    cp_34     139    12348 12487  4082.74  4037.74 -63502
##                    cp_35     139    12348 12487  4287.43  5046.15 -64526
##                    cp_36     139    12348 12487  4048.54  5229.61 -62478
##                    cp_37     139    12348 12487  3566.08  5519.64 -63502
##                    cp_38     139    12348 12487  4264.92  5025.16 -50703
##                    cp_39     139    12348 12487  4238.34  4953.39 -63502
##                     cp_4     138    12349 12487  3211.25  2295.9   -4109
##                    cp_40     139    12348 12487  4268.42  5037.83 -51983
##                    cp_41     139    12348 12487  3976.58  5305.78 -64526
##                    cp_42     139    12348 12487  3963.11  5247.63 -64014
##                    cp_43     139    12348 12487  4228.08  5140.57 -64782
##                    cp_44     139    12348 12487  3971.76  5244.99 -64526
##                    cp_45     139    12348 12487  3988.31  5263.35 -62991
##                    cp_46     139    12348 12487  4138.27  5173.52 -43791
##                    cp_47     139    12348 12487  4385.31  4995.07 -43791
##                    cp_48     139    12348 12487  4391.83  5021.27 -45071
##                    cp_49     139    12348 12487  4034.36  5280.67 -65040
##                     cp_5     138    12349 12487  3226.04  4428.53 -65295
##                    cp_50     139    12348 12487  4032.65  5235.32 -63759
##                    cp_51     139    12348 12487  4046.48  5243.5  -62735
##                    cp_52     139    12348 12487  4037.92  5260.97 -63759
##                    cp_53     139    12348 12487  3937.21  5293.86 -61199
##                    cp_54     139    12348 12487  3921.96  5216.25 -64783
##                    cp_55     139    12348 12487  3929.48  5217.77 -65039
##                    cp_56     139    12348 12487  3923.66  5288.48 -64784
##                    cp_57     139    12348 12487  3890.84  5311.05 -63759
##                    cp_58     139    12348 12487  3908.59  5297.14 -63759
##                    cp_59     140    12347 12487  3908.29  5365.19 -63759
##                     cp_6     138    12349 12487  3656.82  4189.17 -65295
##                    cp_60     140    12347 12487  3673.9   5537.41 -62479
##                    cp_61     140    12347 12487  3895.22  5322.92 -62479
##                    cp_62     140    12347 12487  3869.71  5331.51 -62479
##                    cp_63     140    12347 12487  3948.15  5627.87 -65039
##                    cp_64     140    12347 12487  3916.22  5645.97 -64015
##                    cp_65     140    12347 12487  4407.79  5263.57 -62223
##                    cp_66     140    12347 12487  4022.25  5626.02 -65039
##                    cp_67     140    12347 12487  4433.93  5302.1  -61455
##                    cp_68     140    12347 12487  4446.36  5313.94 -61199
##                    cp_69     140    12347 12487  4426.85  5372.98 -57871
##                     cp_7     138    12349 12487  2403.5   4919.04 -65039
##                    cp_70     140    12347 12487  4031.41  5702.94 -65040
##                    cp_71     140    12347 12487  4031.9   5654.14 -57871
##                    cp_72     140    12347 12487  4024.1   5705.7  -65040
##                    cp_73     140    12347 12487  3986.43  5623.12 -64783
##                    cp_74     140    12347 12487  3982.79  5642.67 -64784
##                    cp_75     140    12347 12487  3997.03  5605.08 -65039
##                    cp_76     140    12347 12487  3978.52  5656.1  -65039
##                    cp_77     140    12347 12487  4345.47  5329.77 -64015
##                    cp_78     140    12347 12487  4362.01  5324.46 -50190
##                    cp_79     140    12347 12487  3932.43  5722.44 -64272
##                     cp_8     138    12349 12487  3471.66  4264.9  -41487
##                    cp_80     140    12347 12487  3975.42  5712.44 -62224
##                    cp_81     140    12347 12487  4109.77  5611.97 -63247
##                    cp_82     140    12347 12487  4117.74  5640.26 -64271
##                    cp_83     140    12347 12487  4108.14  5701.29 -64527
##                    cp_84     140    12347 12487  4121.13  5626.82 -64527
##                    cp_85     140    12347 12487  4089.71  5621.11 -65039
##                    cp_86     140    12347 12487  3954.15  5748.73  -7183
##                    cp_87     140    12347 12487  4502.24  5319.19  -8463
##                    cp_88     140    12347 12487  3881.87  5836.04 -65295
##                    cp_89     140    12347 12487  4040.3   5671.61 -64272
##                     cp_9     138    12349 12487  3611.52  4168    -65039
##                    cp_90     140    12347 12487  4060.84  5763.87 -63503
##                    cp_91     140    12347 12487  4050.38  5679.29 -63503
##                    cp_92     140    12347 12487  4473.62  5478.05 -60430
##                    cp_93     140    12347 12487  4189.53  5647.91 -63247
##                    cp_94     140    12347 12487  4206.59  5697.63 -65039
##                    cp_95     140    12347 12487  4219.04  5721.72 -63248
##                    cp_96     140    12347 12487  4156.42  5727.99  -4066
##             cp_diff (mV)     138    12349 12487   987.85  6731.56      8
##                     GIDs       0    12487 12487   119.39    44.79      0
##          inverter_2 temp       0    12487 12487    48.67    21.73      0
##          inverter_4 temp       0    12487 12487    49.87    22.16      0
##              L1/L2 count       0    12487 12487  1936.73   179.81      0
##              max_cp (mV)     138    12349 12487  4904.48  6512.37   3589
##              min_cp (mV)     138    12349 12487  3916.63   329.91      0
##               Motor temp       0    12487 12487    53.65    22.4       0
##                      ODO       0    12487 12487 14017.91 23684.17      0
##                 QC count       0    12487 12487   169.55    15.79      0
##  Time after power on (s)       0    12487 12487  3778.31  3639.32     30
##      p25    p50      p75  p100     hist
##  3896    3988    4033    60245 ▇▁▁▁▁▁▁▁
##  3848    3973    4032     4294 ▁▁▁▁▁▁▁▇
##  3884    3987    4034    64526 ▁▁▁▁▇▁▁▁
##  3863    3982    4034    65294 ▁▁▁▁▇▁▁▁
##  3887    3983    4030    64782 ▁▁▁▁▇▁▁▁
##  3859    3974    4029    65040 ▁▁▁▁▇▁▁▁
##  3859    3975.5  4030    64783 ▁▁▁▁▇▁▁▁
##  3833    3965    4025    64783 ▁▁▁▁▇▁▁▁
##  3848    3970    4025    64783 ▁▁▁▁▇▁▁▁
##  3878    3983    4033    65039 ▁▁▁▁▇▁▁▁
##  3882    3982    4032    64783 ▁▁▁▇▁▁▁▁
##  3878    3986    4036    65039 ▁▁▁▁▇▁▁▁
##  3877    3984    4034    24834 ▁▁▇▁▁▁▁▁
##  3881    3985    4034    64783 ▁▁▁▇▁▁▁▁
##  3891    3989    4035    65039 ▁▁▁▇▁▁▁▁
##  3891    3988    4036    64784 ▁▁▁▇▁▁▁▁
##  3887    3989    4039    65294 ▁▁▁▇▁▁▁▁
##  3886    3988    4036    64783 ▁▁▁▁▇▁▁▁
##  3887    3985    4034    64783 ▇▁▁▁▁▁▁▁
##  3883    3984    4031    64784 ▁▁▁▇▁▁▁▁
##  3874    3980    4030    65039 ▁▁▁▇▁▁▁▁
##  3875    3981    4029    65039 ▇▁▁▁▁▁▁▁
##  3868.75 3980    4030    65039 ▁▁▁▁▇▁▁▁
##  3841    3971    4034    50785 ▁▁▁▁▇▁▁▁
##  3883    3981    4030    65039 ▁▁▁▁▇▁▁▁
##  3882    3984    4031    65039 ▁▁▁▇▁▁▁▁
##  3882    3983    4030    63759 ▁▁▁▇▁▁▁▁
##  3883    3980    4029    65295 ▁▁▁▁▇▁▁▁
##  3881    3982    4029    65039 ▁▁▁▁▇▁▁▁
##  3882    3979    4025    65039 ▁▁▁▁▇▁▁▁
##  3869    3979    4030    64783 ▁▁▁▁▇▁▁▁
##  3841    3969    4030    65039 ▁▁▁▁▇▁▁▁
##  3883    3979    4025    64783 ▁▁▁▇▁▁▁▁
##  3883    3983    4029    65039 ▁▁▁▁▇▁▁▁
##  3846    3974    4032     4117 ▁▁▁▁▁▁▁▇
##  3884    3980    4026    65039 ▁▁▁▇▁▁▁▁
##  3869    3980    4030    65039 ▁▁▁▁▇▁▁▁
##  3866.75 3980    4030    64783 ▁▁▁▁▇▁▁▁
##  3883    3987    4034    65039 ▁▁▁▁▇▁▁▁
##  3866    3984    4034    64016 ▁▁▁▁▇▁▁▁
##  3873    3983    4034    64782 ▁▁▁▁▇▁▁▁
##  3878    3984    4030    65039 ▁▁▁▇▁▁▁▁
##  3889    3988    4034    65039 ▁▁▁▇▁▁▁▁
##  3890    3989    4036    65039 ▁▁▁▇▁▁▁▁
##  3886    3982    4033    65039 ▁▁▁▁▇▁▁▁
##  3834    3965    4028    65294 ▁▁▁▁▇▁▁▁
##  3883    3980    4025    65039 ▁▁▁▁▇▁▁▁
##  3883    3979    4026    65039 ▁▁▁▁▇▁▁▁
##  3883    3979    4026.25 64783 ▁▁▁▁▇▁▁▁
##  3882    3983    4034    64783 ▁▁▁▁▇▁▁▁
##  3878    3981    4030    64782 ▁▁▁▁▇▁▁▁
##  3881    3979    4030    64782 ▁▁▁▁▇▁▁▁
##  3879    3980    4029    64783 ▁▁▁▁▇▁▁▁
##  3878    3978    4029    64783 ▁▁▁▁▇▁▁▁
##  3878    3978    4029    65039 ▁▁▁▁▇▁▁▁
##  3877    3982    4033    64783 ▁▁▁▁▇▁▁▁
##  3864    3978    4029    65295 ▁▁▁▁▇▁▁▁
##  3856    3974    4030    64783 ▁▁▁▁▇▁▁▁
##  3877    3982    4033    64783 ▁▁▁▁▇▁▁▁
##  3874    3976    4025    64783 ▁▁▁▁▇▁▁▁
##  3874    3975    4025    64783 ▁▁▁▁▇▁▁▁
##  3874    3975    4025    65039 ▁▁▁▁▇▁▁▁
##  3897    3988    4032    65039 ▁▁▁▁▇▁▁▁
##  3883    3984    4031    65038 ▁▁▁▁▇▁▁▁
##  3897    3988    4034    65039 ▁▁▁▁▇▁▁▁
##  3897    3985    4034    64783 ▁▁▁▁▇▁▁▁
##  3892    3984    4033    65040 ▁▁▁▁▇▁▁▁
##  3743    3931    4023    64783 ▁▁▁▂▇▁▁▁
##  3882    3978    4028    65039 ▁▁▁▁▇▁▁▁
##  3879    3978    4028    64783 ▁▁▁▁▇▁▁▁
##  3878    3979    4027    64783 ▁▁▁▁▇▁▁▁
##  3872    3975    4026    64783 ▁▁▁▁▇▁▁▁
##  3871    3975    4027    64783 ▁▁▁▁▇▁▁▁
##  3872    3977    4027    64783 ▁▁▁▁▇▁▁▁
##  3871    3976    4031    64782 ▁▁▁▁▇▁▁▁
##  3890    3983    4033    65038 ▁▁▁▁▇▁▁▁
##  3892    3986    4036    65294 ▁▁▁▇▁▁▁▁
##  3875    3982    4036    65294 ▁▁▁▁▇▁▁▁
##  3846    3974    4030    65039 ▁▁▁▇▁▁▁▁
##  3875    3981    4033    65295 ▁▁▁▁▇▁▁▁
##  3882.5  3983    4031    65294 ▁▁▁▁▇▁▁▁
##  3883    3984    4034    65294 ▁▁▁▁▇▁▁▁
##  3882    3983    4030    64783 ▁▁▁▁▇▁▁▁
##  3884    3984    4034    65295 ▁▁▁▁▇▁▁▁
##  3880    3977    4028    64784 ▁▁▁▁▇▁▁▁
##  3864    3976    4033    65039 ▁▇▁▁▁▁▁▁
##  3894    3982    4032    65039 ▁▇▁▁▁▁▁▁
##  3866    3977    4031    65039 ▁▁▁▁▇▁▁▁
##  3884    3981    4032.5  65295 ▁▁▁▁▇▁▁▁
##  3862    3978    4030    63503 ▁▁▁▁▇▁▁▁
##  3882    3982    4033    65038 ▁▁▁▁▇▁▁▁
##  3883    3981    4032    65294 ▁▁▁▁▇▁▁▁
##  3896    3985    4032    65295 ▁▁▁▁▇▁▁▁
##  3886    3980    4028    65039 ▁▁▁▁▇▁▁▁
##  3886    3982    4030    64783 ▁▁▁▁▇▁▁▁
##  3886    3984    4032    65295 ▁▁▁▁▇▁▁▁
##  3869    3979    4034    65038 ▇▁▁▁▁▁▁▁
##    16      18      23    65295 ▇▁▁▁▁▁▁▁
##    86     124     156      202 ▁▂▅▆▇▇▇▃
##    25      61      66       86 ▁▅▅▁▁▇▇▁
##    26      61      67       82 ▁▂▅▁▁▃▇▂
##  1924    1950    1979     2001 ▁▁▁▁▁▁▁▇
##  3906    3997    4042    65295 ▇▁▁▁▁▁▁▁
##  3874    3975    4024     4103 ▁▁▁▁▁▁▁▇
##    30      64      71       92 ▁▃▆▁▁▇▇▁
##     0       0   53114    54902 ▇▁▁▁▁▁▁▃
##   169     169     175      175 ▁▁▁▁▁▁▁▇
##   784    2486    6028.5  16636 ▇▃▂▂▁▁▁▁
## 
## ── Variable type:numeric ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
##                 variable missing complete     n   mean      sd      p0
##       12V battery (amps)       0    12487 12487   1.62    2.48  -10.91
##  12V battery (dashboard)       0    12487 12487   0       0       0   
##      12V battery (volts)       0    12487 12487  12.83    1.27    0   
##                  ACC (V)       0    12487 12487  12.74    3.29    0   
##                      AHr       0    12487 12487  46.92    8.5     0   
##                 Altitude      12    12475 12487  42.41   25.14 -293.5 
##           ambient_temp_1       0    12487 12487  13.03    3.84    0   
##             cabin_temp_1       0    12487 12487 178.58   62.88    0   
##             cabin_temp_2       0    12487 12487 178.58   62.88    0   
##           Charger (amps)       0    12487 12487  11.77    6.92    0   
##              Charger (V)       0    12487 12487 153.03  114.59    0   
##                 h_volt_1       0    12487 12487 373.58   54.57    0   
##                       Hx       0    12487 12487  50.78   23.82    0   
##            motor_amp (1)       0    12487 12487 284.21 1002.6     0   
##            motor_amp (2)       0    12487 12487 284.14 1006.32    0   
##          Pack 1 temp (C)     139    12348 12487  19.9     3.37    8.7 
##          Pack 2 temp (C)     168    12319 12487  19.03    3.38    7.6 
##          Pack 3 temp (C)     191    12296 12487  18.61    3.23    7.7 
##          Pack 4 temp (C)     191    12296 12487  17.8     3.17    7.6 
##                Pack amps       0    12487 12487  -5.44    9.21  -32.75
##               Pack volts       0    12487 12487 421.65  391.92    0   
##                      SOC       0    12487 12487  57.55   21.03    0   
##                      SOH       0    12487 12487  71.5     7.64    0   
##          SOH (version 2)       0    12487 12487  68.94   15.11    0   
##              Speed (GPS)      12    12475 12487  10.35   24.91    0   
##      Speed (Speedometer)       0    12487 12487  10.43   23.75    0   
##   target_regen_braking_1       0    12487 12487  12.11   93.64    0   
##   target_regen_braking_2       0    12487 12487  53.24  304.3     0   
##                 throttle       0    12487 12487   4.66   13.7     0   
##     p25    p50    p75    p100     hist
##    1.11   1.36   2.09   40.62 ▁▇▃▁▁▁▁▁
##    0      0      0       0    ▁▁▁▇▁▁▁▁
##   12.96  12.96  12.96   14.72 ▁▁▁▁▁▁▁▇
##   12.82  12.85  12.87   64    ▁▇▁▁▁▁▁▁
##   47.38  47.44  47.48  132.74 ▁▁▇▁▁▁▁▁
##   36     39.8   44.2   395.1  ▁▁▁▇▂▁▁▁
##   11     14     16      22    ▁▁▂▃▃▇▅▁
##  214    214    214     214    ▁▁▂▁▁▁▁▇
##  214    214    214     214    ▁▁▂▁▁▁▁▇
##    0     15.62  15.62   33.44 ▃▁▁▇▁▁▁▁
##    1.05 238.74 241.16  249.45 ▅▁▁▁▁▁▁▇
##  373.33 382.42 386.98  655.35 ▁▁▁▁▇▁▁▁
##   50.39  50.49  50.53  625.5  ▇▁▁▁▁▁▁▁
##    0      0      0    4095    ▇▁▁▁▁▁▁▁
##    0      0      0    4095    ▇▁▁▁▁▁▁▁
##   17.6   20.2   21.8    28.4  ▁▁▂▅▇▆▃▁
##   16.8   19.4   21.1    27.7  ▁▂▂▅▇▆▃▁
##   16.4   19     20.7    26.2  ▁▁▂▅▆▇▃▁
##   15.5   18.2   20      25.1  ▁▂▂▆▇▇▅▁
##   -8.91  -8.15  -0.88   32.75 ▁▁▇▆▂▁▁▁
##  373.63 382.75 387.17 5783.52 ▇▁▁▁▁▁▁▁
##   42.41  60     74.56   95.53 ▁▂▃▆▆▇▇▃
##   72.22  72.31  72.38   72.86 ▁▁▁▁▁▁▁▇
##   72.22  72.31  72.38   72.86 ▁▁▁▁▁▁▁▇
##    0      0      0     103.71 ▇▁▁▁▁▁▁▁
##    0      0      0     102.08 ▇▁▁▁▁▁▁▁
##    0      0      0    1258    ▇▁▁▁▁▁▁▁
##    0      0      0    4092    ▇▁▁▁▁▁▁▁
##    0      0      0     199    ▇▁▁▁▁▁▁▁
```

# Runtime




Analysis completed in 34.87 seconds ( 0.58 minutes) using [knitr](https://cran.r-project.org/package=knitr) in [RStudio](http://www.rstudio.com) with R version 3.5.0 (2018-04-23) running on x86_64-apple-darwin15.6.0.

# R environment

R packages used:

 * base R - for the basics [@baseR]
 * data.table - for fast (big) data handling [@data.table]
 * lubridate - date manipulation [@lubridate]
 * ggplot2 - for slick graphics [@ggplot2]
 * readr - for csv reading/writing [@readr]
 * skimr - for skim [@skimr]
 * knitr - to create this document & neat tables [@knitr]
 * nzGREENGrid - for local NZ GREEN Grid project utilities

Session info:


```
## R version 3.5.0 (2018-04-23)
## Platform: x86_64-apple-darwin15.6.0 (64-bit)
## Running under: macOS High Sierra 10.13.5
## 
## Matrix products: default
## BLAS: /Library/Frameworks/R.framework/Versions/3.5/Resources/lib/libRblas.0.dylib
## LAPACK: /Library/Frameworks/R.framework/Versions/3.5/Resources/lib/libRlapack.dylib
## 
## locale:
## [1] en_GB.UTF-8/en_GB.UTF-8/en_GB.UTF-8/C/en_GB.UTF-8/en_GB.UTF-8
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] bindrcpp_0.2.2    knitr_1.20        skimr_1.0.3       readr_1.1.1      
## [5] lubridate_1.7.4   ggplot2_2.2.1     dplyr_0.7.5       data.table_1.11.4
## [9] nzGREENGrid_0.1.0
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.17      pillar_1.2.3      compiler_3.5.0   
##  [4] plyr_1.8.4        bindr_0.1.1       prettyunits_1.0.2
##  [7] tools_3.5.0       progress_1.2.0    digest_0.6.15    
## [10] gtable_0.2.0      evaluate_0.10.1   tibble_1.4.2     
## [13] pkgconfig_2.0.1   rlang_0.2.1       cli_1.0.0        
## [16] rstudioapi_0.7    yaml_2.1.19       xfun_0.1         
## [19] stringr_1.3.1     hms_0.4.2         rprojroot_1.3-2  
## [22] grid_3.5.0        tidyselect_0.2.4  glue_1.2.0       
## [25] R6_2.2.2          rmarkdown_1.10    bookdown_0.7     
## [28] tidyr_0.8.1       purrr_0.2.5       reshape2_1.4.3   
## [31] magrittr_1.5      scales_0.5.0      backports_1.1.2  
## [34] htmltools_0.3.6   assertthat_0.2.0  colorspace_1.3-2 
## [37] stringi_1.2.3     lazyeval_0.2.1    munsell_0.5.0    
## [40] crayon_1.3.4
```

# References
