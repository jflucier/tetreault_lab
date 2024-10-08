
import argparse
from DeepSlice import DSModel

def launch_deepslice(species, images_path, outfile, ensemble, section):
    #available species are 'mouse' and 'rat'

    Model = DSModel(species)

    # here you run the model on your folder
    # try with and without ensemble to find the model which best works for you
    # if you have section numbers included in the filename as _sXXX specify this :)
    Model.predict(images_path, ensemble=ensemble, section_numbers=section)
    # If you would like to normalise the angles (you should)
    Model.propagate_angles()
    # To reorder your sections according to the section numbers
    Model.enforce_index_order()
    # alternatively if you know the precise spacing (ie; 1, 2, 4, indicates that section 3 has been left out of the
    # series) Then you can use Furthermore if you know the exact section thickness in microns this can be included
    # instead of None if your sections are numbered rostral to caudal you will need to specify a negative section_thickness
    Model.enforce_index_spacing(section_thickness=None)
    # now we save which will produce a json file which can be placed in the same directory as your images and then opened
    # with QuickNII.
    Model.save_predictions(images_path + outfile)

    print(f"{outfile} was saved in {images_path} and can be passed to VisuAlign tool for .flat files generation. ")

if __name__ == '__main__':
    argParser = argparse.ArgumentParser()

    # mandatory
    argParser.add_argument(
        "-s",
        "--specie",
        help="species name",
        required=True
    )

    argParser.add_argument(
        "-i",
        "--images_path",
        help="Images input path",
        required=True
    )

    argParser.add_argument(
        "-o",
        "--output_file",
        help="Output filename",
        required=True
    )

    argParser.add_argument(
        "-e",
        "--ensemble",
        help="ensemble predict parameter",
        required=True,
        default=True,
        type=bool
    )

    argParser.add_argument(
        "-x",
        "--section",
        help="section predict parameter",
        required=True,
        default=True,
        type=bool
    )

    args = argParser.parse_args()

    launch_deepslice(
        args.specie,
        args.images_path,
        args.output_file,
        args.ensemble,
        args.section,
    )