using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PixelizeFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class PixelizePassSettings {
        public int screenHeight = 144;
    }

    [SerializeField]
    private PixelizePassSettings pixelizePassSettings = new PixelizePassSettings();

    private PixelizePass pixelizePass;
    private RTHandle tmp_RT;

    /// <inheritdoc/>
    public override void Create()
    {
        pixelizePass = new PixelizePass();
        pixelizePass.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
#if UNITY_EDITOR
        if (renderingData.cameraData.isSceneViewCamera) return;
#endif
        renderer.EnqueuePass(pixelizePass);
    }

    public override void SetupRenderPasses(ScriptableRenderer renderer, in RenderingData renderingData) {
        pixelizePass.Setup(pixelizePassSettings, renderer.cameraColorTargetHandle, tmp_RT);
    }

    protected override void Dispose(bool disposing) {
        tmp_RT?.Release();
    }
}


