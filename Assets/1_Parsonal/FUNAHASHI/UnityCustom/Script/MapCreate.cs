using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

public class MapCreate : MonoBehaviour
{
    // CSVファイル変数
    [SerializeField] private string csvFile;

    // オブジェクト番号配列
    [SerializeField]
    List<GameObject> csvObjList = new List<GameObject>();

    public float tileSize = 1f; // タイルのサイズ

    // Start is called before the first frame update
    void Start()
    {
        // CSVファイルのパスを取得
        string filePath = Path.Combine(Application.dataPath, csvFile);

        // CSVファイルが存在するかを確認
        if (File.Exists(filePath))
        {
            // CSVファイルの内容を読み込む
            string[] lines = File.ReadAllLines(filePath);

            // 行ごとに処理
            for (int y = 0; y < lines.Length; y++)
            {
                string[] values = lines[y].Split(',');

                // 列ごとに処理
                for (int x = 0; x < values.Length; x++)
                {
                    if (values[x] == "") continue; // 空の場合はスキップ
                    int tileIndex = int.Parse(values[x]);


                    // 対応するタイルのプレハブが存在するか確認
                    if (tileIndex >= 0 && tileIndex < csvObjList.Count&& csvObjList[tileIndex] != null)
                    {
                        // タイルの位置を計算
                        Vector3 tilePosition = new Vector3(x * tileSize, 0f, -y * tileSize);

                        // タイルを生成
                        GameObject tile = Instantiate(csvObjList[tileIndex], tilePosition, Quaternion.identity);
                        if (tile == null) continue;
                        tile.transform.SetParent(transform); // マップの子オブジェクトに設定

                    }
                }
            }
        }
        else
        {
            Debug.LogError("CSVファイルが見つかりません: " + filePath);
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
