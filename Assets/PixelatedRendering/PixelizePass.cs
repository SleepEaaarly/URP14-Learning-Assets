using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PixelizePass : ScriptableRenderPass
{

    private int screenHeight;

    public void Setup (PixelizeFeature.PixelizePassSettings settings) {
        screenHeight = settings.screenHeight;
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData) {
        throw new System.NotImplementedException();
    }
}
