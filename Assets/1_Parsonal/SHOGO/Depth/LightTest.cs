using System.Collections.Generic;
using UnityEngine;

public class LightTest : MonoBehaviour
{
    Mesh mesh;
    //[SerializeField]
    MeshFilter filter;
    // 光源オブジェクト
    [SerializeField]
    List<GameObject> lightObjects = new List<GameObject>();
    // 壁に設定しているレイヤー
    [SerializeField]
    LayerMask layerMask;
    // 頂点情報格納用list
    private List<Vector3> verticesList;
    private List<Color> colorList;
    [SerializeField]
    int vertexNum;
    void Start()
    {
        // MeshFilterを取得してMeshを取得する
        filter = GetComponent<MeshFilter>();
        mesh = filter.mesh;

        // 頂点座標を変更する関数を呼び出す
        //ModifyVertices();
        if(lightObjects != null)
        {
            Debug.Log("lightobjが未設定");
        }
        verticesList = new List<Vector3>();
        colorList = new List<Color>();
    }

    void CheckClip()
    {
        // 現在のMeshの頂点座標を取得する
        mesh.GetVertices(verticesList);
        vertexNum=verticesList.Count;
        // 頂点カラーListのクリア
        colorList.Clear();
        Vector3 vertexPosition;
        int i, j;
        // 各頂点座標に応じて変更する処理を行う
        for ( i = 0; i < verticesList.Count; i++)
        {
            // ワールド座標に変換した頂点座標を取得
            vertexPosition=transform.TransformPoint(verticesList[i]);
           // 頂点座標から光源オブジェクトにむけてRayを飛ばす
           for( j=0;j<lightObjects.Count;j++)
            {
                if (!(Physics.Linecast(vertexPosition, lightObjects[j].transform.position, layerMask)))
                {
                    colorList.Add(Color.white);
                    //Debug.DrawLine(vertexPosition, lightObjects[j].transform.position, Color.blue)
                    break;
                }
                else
                {
                    //Debug.DrawLine(vertexPosition, lightObjects[j].transform.position, Color.red);
                }
            }
           if(j==lightObjects.Count)
            {
                colorList.Add(Color.black);
                ;

            }

        }
        // 変更した頂点カラーをMeshに適用する
        mesh.SetColors(colorList);
    }
    void Update()
    {
        CheckClip();
    }
}
