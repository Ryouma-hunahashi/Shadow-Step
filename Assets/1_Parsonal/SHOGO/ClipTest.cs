using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ClipTest : MonoBehaviour
{
    private Material m_Material;
    private GameObject m_PlayeObject;
    [SerializeField] float m_drawRange=10;
    // Start is called before the first frame update
    void Start()
    {
        // Materialの取得
        m_Material =GetComponent<MeshRenderer>().material;
        if(m_Material == null)
        {
            Debug.Log("Materialが存在しません");
        }
        // プレイヤーオブジェクトの取得
        m_PlayeObject = GameObject.FindWithTag("Player");
        if(m_PlayeObject == null)
        {
            Debug.LogError("プレイヤーオブジェクトが存在しません");
        }
        m_Material.SetFloat("DrawRange", m_drawRange);
    }

    // Update is called once per frame
    void Update()
    {
        // プレイヤー座標の参照
        m_Material.SetVector("_PlayerPosition", m_PlayeObject.transform.position);
        // 描画範囲の設定
        m_Material.SetFloat("_DrawRange", m_drawRange);
    }
}
