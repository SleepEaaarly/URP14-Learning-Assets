using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PixelizePass : ScriptableRenderPass
{
    public PixelizePass(PixelizeFeature.PixelizePassSettings settings) {

    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData) {
        throw new System.NotImplementedException();
    }
}
