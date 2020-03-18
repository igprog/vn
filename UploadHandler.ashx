﻿<%@ WebHandler Language="C#" Class="UploadHandler" %>

using System;
using System.Web;
using System.IO;

using System.Linq;
using System.Configuration;
using ImgResizerLib;

public class UploadHandler : IHttpHandler {

    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";
        string imgId = context.Request.Form["imgId"];

        string imgFolder = context.Request.Form["imgFolder"];

        if (context.Request.Files.Count > 0) {
            HttpFileCollection files = context.Request.Files;
            for (int i = 0; i < files.Count; i++) {
                HttpPostedFile file = files[i];
                //string fname = context.Server.MapPath(string.Format("~/upload/{0}/gallery/{1}", imgId, file.FileName));

                string fname = null;
                string fname_thumb = null;
                if (string.IsNullOrEmpty(imgFolder)) {
                    fname = context.Server.MapPath(string.Format("~/upload/{0}/gallery/{1}", imgId, file.FileName));
                    fname_thumb = context.Server.MapPath(string.Format("~/upload/{0}/gallery/thumb/{1}", imgId, file.FileName));
                } else {
                    fname = context.Server.MapPath(string.Format("~/upload/{0}/{1}", imgFolder, imgId));
                }

                if (!string.IsNullOrEmpty(file.FileName)) {

                    //string folderPath = context.Server.MapPath(string.Format("~/upload/{0}/gallery", imgId));

                    string folderPath = null;
                        string folderPath_thumb = null;
                    if (string.IsNullOrEmpty(imgFolder)) {
                        folderPath = context.Server.MapPath(string.Format("~/upload/{0}/gallery", imgId));
                        folderPath_thumb = context.Server.MapPath(string.Format("~/upload/{0}/gallery/thumb", imgId));
                    } else {
                        folderPath = context.Server.MapPath(string.Format("~/upload/{0}", imgFolder));
                    }

                    if (!Directory.Exists(folderPath)) {
                        Directory.CreateDirectory(folderPath);
                    }
                    if (!Directory.Exists(folderPath_thumb)) {
                        Directory.CreateDirectory(folderPath_thumb);
                    }

                    if (CheckGalleryLimit(folderPath)) {
                        file.SaveAs(fname);
                            int thumbSizeWidth = Convert.ToInt32(ConfigurationManager.AppSettings["thumbSizeWidth"]);
                            int thumbSizeHeight = Convert.ToInt32(ConfigurationManager.AppSettings["thumbSizeHeight"]);
                        ImgResizer.PerformImageResizeAndPutOnCanvas(fname, fname_thumb, thumbSizeWidth, thumbSizeHeight, file.FileName);
                        context.Response.Write(imgId);
                    } else {
                        context.Response.Write("product limit exceeded");  //TODO
                    }
                } else {
                    context.Response.Write("please choose a file to upload");
                }
            }
        }
    }

    public bool IsReusable {
        get {
            return false;
        }
    }

    private bool CheckGalleryLimit(string path) {
        int count = 0;
        int productsLimit = Convert.ToInt32(ConfigurationManager.AppSettings["galleryLimit"]);
        if (Directory.Exists(path)) {
            string[] ss = Directory.GetFiles(path);
            count = ss.Count();
        }
        return count <= productsLimit ? true : false;
    }

}