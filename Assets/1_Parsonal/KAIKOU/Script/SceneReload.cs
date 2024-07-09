using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneReload : MonoBehaviour
{
    [SerializeField] private GameObject[] reloadObj;
    private ControlManager controlManager;

    // Start is called before the first frame update
    void Start()
    {
        controlManager = GetComponent<ControlManager>();
        if (controlManager == null) Debug.LogError("コントロールマネージャーを設定してください" + this.name);
    }

    // Update is called once per frame
    void Update()
    {
        if (controlManager.GetVariousInput(ControlManager.E_TYPE.PRESSED, ControlManager.E_KB.R))
        {
            //foreach(GameObject obj in reloadObj)
            //{
            //    if(!obj.activeSelf) obj.SetActive(true);

            //}
            Application.LoadLevel(SceneManager.GetActiveScene().name);
        }
    }
}
