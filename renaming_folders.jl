
using Dates
#copy and paste the folder path which has all the folders
main_folder = "C:\\Users\\j.sharma\\OneDrive - Scuola Superiore Sant'Anna\\P10 Microfabrication\\Experiments\\2024\\05.May\\13\\exp2\\"

folders = filter(x -> isdir(joinpath(main_folder, x)), readdir(main_folder))


for dir in folders
    # Split the folder name by _          ....you can split with any symbol that you have in folders, e.g =
    parts = split(dir, '_')
    
    
    if length(parts) >= 2
        # Create the new name by joining the first two parts, you can join any number of paths
        new_name = join(parts[1:2], "_") # you can design the name
        old_path = joinpath(main_folder, dir)
        new_path = joinpath(main_folder, new_name)
        
        # Rename the folder
        mv(old_path, new_path, force=true)
        
    else
        println("Skipping: $dir (does not have enough parts)")
    end
end

println("Done renaming folders.")