using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RenderManager : MonoBehaviour
{
    public RenderTexture outTexture;
    public string outPath;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(Time.frameCount > 10) {
            SaveRenderTexture(outTexture, outPath + Time.frameCount + "-" + Time.realtimeSinceStartup + ".png");
        }

        if(Time.frameCount > 20) {
            Debug.Log("QUIT");
            Application.Quit();
        }
    }
    static void SaveRenderTexture(RenderTexture rt, string path)
    {
        RenderTexture.active = rt;
        Texture2D tex = new Texture2D(rt.width, rt.height, TextureFormat.RGB24, false);
        tex.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
        RenderTexture.active = null;
        var bytes = tex.EncodeToPNG();
        System.IO.File.WriteAllBytes(path, bytes);
        Debug.Log($"Saved texture: {rt.width}x{rt.height} - " + path);
    }
}
