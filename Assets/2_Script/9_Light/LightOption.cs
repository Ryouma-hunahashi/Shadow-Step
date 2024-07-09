using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightOption : MonoBehaviour
{
    private UI_Option option;
    private Light light;

    private float defIntens;

    // Start is called before the first frame update
    void Start()
    {
        light = GetComponent<Light>();
        defIntens = light.intensity;
        UI_Option[] objs = FindObjectsOfType<UI_Option>();
        option = objs[objs.Length - 1];
    }

    // Update is called once per frame
    void Update()
    {
        light.intensity = defIntens + (option.GetLightSlider().slider.value - 0.5f) * 2;
    }
}
