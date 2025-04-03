using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PixelizePass : ScriptableRenderPass
{

    private int screenHeight;
    private RTHandle source;
    private RTHandle destination;
    private Material material;

    public void Setup (PixelizeFeature.PixelizePassSettings settings, RTHandle src, RTHandle dst) {
        screenHeight = settings.screenHeight;
        source = src;
        destination = dst;
        if (material == null) material = CoreUtils.CreateEngineMaterial("Custom/PixelizeShader");

    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData) {
        CommandBuffer cmd = CommandBufferPool.Get("PixelizePass");

        // var source = renderingData.cameraData.renderer.cameraColorTargetHandle;

        Vector2 viewportScale = source.useScaling ? new Vector2(source.rtHandleProperties.rtHandleScale.x, source.rtHandleProperties.rtHandleScale.y) : Vector2.one;
        Blitter.BlitTexture(cmd, source, viewportScale, material, 0);

        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }
}
