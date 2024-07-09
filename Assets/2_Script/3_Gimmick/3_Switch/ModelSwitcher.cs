using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ModelSwitcher : MonoBehaviour
{
    enum E_MODEL_SWITCES
    { 
        FALSE,
        TRUE,
    }

    private VariousSwitches switches;
    private bool switchLog  = false;

    [SerializeField]private GameObject mod_SwitchOn;
    [SerializeField]private GameObject mod_SwitchOff;


    // Start is called before the first frame update
    void Start()
    {
        switches = GetComponent<VariousSwitches>();
        if (switches == null) { Debug.LogError("スイッチがないです"); }

        switchLog = switches.nowSwitchStatus;

        mod_SwitchOff.SetActive(!switchLog);
        mod_SwitchOn.SetActive(switchLog);

    }

    // Update is called once per frame
    void Update()
    {
        if(switchLog!=switches.nowSwitchStatus)
        {
            switchLog = switches.nowSwitchStatus;

            mod_SwitchOff.SetActive(!switchLog);
            mod_SwitchOn.SetActive(switchLog);
        }
    }
}
