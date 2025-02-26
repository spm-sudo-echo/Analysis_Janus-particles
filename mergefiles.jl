# to merge diffrerent files into one file
using CSV, DataFrames, FileIO

path = raw"C:\Users\j.sharma\OneDrive - Scuola Superiore Sant'Anna\P10 Microfabrication\Experiments\2024\12.December\05\exp1\\" # path to the folder containing the files to be merged
file1 = "VID001.aviVID001analysis_eqR_ellipse21.csv" # name of the first file to be merged
file2 = "VID001.aviVID001analysis_eqL_ellipse21.csv" # name of the second file to be merged 
file3 = "VID001.aviVID001analysis_poleU_ellipse21.csv" # name of the third file to be merged      
file4 = "VID001.aviVID001analysis_poleD_ellipse21.csv" # name of the fourth file to be merged

df1 = CSV.read(path*file1, DataFrame)
df2 = CSV.read(path*file2, DataFrame)
df3 = CSV.read(path*file3, DataFrame)
df4 = CSV.read(path*file4, DataFrame)

t_stamp= df1[:,1]/12

df = DataFrame(t_stamp= t_stamp, eqR= df1[:,2], eqL= df2[:,2], poleU= df3[:,2], poleD= df4[:,2])

df5= DataFrame(t_stamp= t_stamp, curvature_diff= df1[:,2]+df2[:,2]-df3[:,2]-df4[:,2])
CSV.write(path*"analysis_VID001.csv", df)
CSV.write(path*"analysis_VID001_curvature_diff.csv", df5)