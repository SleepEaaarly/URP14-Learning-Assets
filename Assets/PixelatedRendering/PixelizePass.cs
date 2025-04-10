using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PixelizePass : ScriptableRenderPass
{

    private int screenHeight;
    private int screenWidth;
    private RTHandle source;
    private RTHandle destination;
    private RTHandle grabTexture;
    private Material material;

    public void Setup (PixelizeFeature.PixelizePassSettings settings, RTHandle src, RTHandle dst) {
        screenHeight = settings.screenHeight;
        source = src;
        destination = dst;
    }

    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData) {
        RenderTextureDescriptor descriptor = renderingData.cameraData.cameraTargetDescriptor;
        descriptor.msaaSamples = 1;
        descriptor.depthBufferBits = 0;

        RenderingUtils.ReAllocateIfNeeded(ref destination, descriptor, FilterMode.Point, TextureWrapMode.Clamp, name: "_tmp_RT");
        RenderingUtils.ReAllocateIfNeeded(ref grabTexture, descriptor, FilterMode.Point, TextureWrapMode.Clamp, name: "_GrabTexture");

        if (material == null) material = CoreUtils.CreateEngineMaterial("Custom/PixelizeShader");
        
        float aspect = renderingData.cameraData.camera.aspect;
        screenWidth = (int)(screenHeight * aspect + 0.5f);
        material.SetVector("_BlockCount", new Vector2(screenWidth, screenHeight));
        material.SetVector("_BlockSize", new Vector2(1.0f / screenWidth, 1.0f / screenHeight));
        material.SetVector("_HalfBlockSize", new Vector2(0.5f / screenWidth, 0.5f / screenHeight));
        cmd.SetGlobalTexture("_GrabTexture", grabTexture.nameID);
        ConfigureTarget(grabTexture);
        ConfigureClear(ClearFlag.All, Color.clear);
        // material.SetTexture("_GrabTexture", grabTexture);
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData) {
        CommandBuffer cmd = CommandBufferPool.Get("PixelizePass");

        Blitter.BlitCameraTexture(cmd, source, destination, material, 0);
        Blitter.BlitCameraTexture(cmd, destination, source);

        context.ExecuteCommandBuffer(cmd);
        cmd.Clear();
        CommandBufferPool.Release(cmd);
    }
}
