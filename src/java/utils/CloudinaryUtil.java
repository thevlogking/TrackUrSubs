package utils;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;

import jakarta.servlet.http.Part;

import java.io.File;
import java.util.Map;

public class CloudinaryUtil {

    private static final Cloudinary cloudinary =

    new Cloudinary(

    ObjectUtils.asMap(

    "cloud_name",
    "dmwl8pgdx",

    "api_key",
    "718363597654747",

    "api_secret",
    "Vp5XLFOqtX6ufkl5uDaYhwvD19U"

    )

    );

    public static String uploadImage(
    Part filePart
    ) throws Exception {

        if(filePart == null ||
        filePart.getSize() == 0){

            return null;

        }

        String fileName =

        filePart
        .getSubmittedFileName();

        File tempFile =

        File.createTempFile(
        "trackursubs_",
        "_" + fileName
        );

        filePart.write(
        tempFile.getAbsolutePath()
        );

        Map result =

        cloudinary.uploader().upload(

        tempFile,

        ObjectUtils.asMap(

        "folder",

        "trackursubs_profiles"

        )

        );

        tempFile.delete();

        return result
        .get("secure_url")
        .toString();

    }

}