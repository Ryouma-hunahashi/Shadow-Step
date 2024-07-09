using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FenceStyle : MonoBehaviour
{
    //[Header("檻の本数（自動設定）"), SerializeField]
    //private int numFence = 0; // 檻の数

    [Header("檻オブジェクト（プレハブ用）"), SerializeField]
    private GameObject prefabFence = null;

    [Header("檻の間隔"), Range(0.0f, 1.0f), SerializeField]
    private float startWidth = 1.0f;

    [Header("オブジェクト確認用"), SerializeField]
    private List<GameObject> fences = new List<GameObject>(); // 個々の檻オブジェクト格納

    void Awake()
    {
        Destroy(this.gameObject.transform.GetComponent<MeshFilter>());
        Destroy(this.gameObject.transform.GetComponent<MeshRenderer>());

        if(prefabFence == null)
        {
            Debug.LogError("プレハブ化した檻オブジェクトが存在しません");
            return;
        }

        // 檻の原点用オブジェクトを取得
        GameObject centerObj = this.transform.GetChild(0).transform.gameObject;
        if(centerObj == null)
        {
            Debug.LogError("中心用子オブジェクトが存在しません");
            return;
        }


        // グローバル座標の原点にする
        centerObj.transform.parent = null; // 一旦、親子関係を切る
        centerObj.transform.position = Vector3.zero;
        centerObj.transform.rotation = Quaternion.identity;


        // X軸のScaleで檻の本数を指定（四捨五入）
        int numFence = Mathf.Abs(Mathf.RoundToInt(this.transform.localScale.x));


        GameObject obj = null; // 追加オブジェクト保持用
        float width = startWidth;
        float saveWidth = 0.0f; // 間隔の値の保持用


        // 檻の本数が奇数なら
        // 中心に檻オブジェクトを生成
        if (numFence % 2 == 1)
        {
            obj = Instantiate(prefabFence, Vector3.zero, Quaternion.identity);
            obj.transform.position = Vector3.zero;
            obj.transform.parent = centerObj.transform;
            fences.Add(obj);
        }
        else
        {
            width /= 2.0f;
            saveWidth = width;
        }


        // 間隔をズラしながら本数分、
        // 檻オブジェクトを生成
        for (int i = 0; i < numFence / 2; i++)
        {
            obj = Instantiate(prefabFence, Vector3.zero, Quaternion.identity);
            obj.transform.position = Vector3.right * (width * (i + 1) + saveWidth * i);
            obj.transform.parent = centerObj.transform;
            fences.Add(obj);
            obj = Instantiate(prefabFence, Vector3.zero, Quaternion.identity);
            obj.transform.position = -Vector3.right * (width * (i + 1) + saveWidth * i);
            obj.transform.parent = centerObj.transform;
            fences.Add(obj);
        }

        // 檻の原点を元の座標に戻す
        centerObj.transform.rotation = this.transform.rotation;
        centerObj.transform.parent = this.transform; // 親子関係を復元
        centerObj.transform.localPosition = Vector3.zero;
    }
}
