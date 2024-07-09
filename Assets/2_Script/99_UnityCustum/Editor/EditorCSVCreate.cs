using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

public class EditorCSVCreate : EditorWindow
{
    string folderPath;
    string csvFileName;
    GameObject mapObject;

    // �I�u�W�F�N�g�ԍ��z��
    [SerializeField]
    List<GameObject> csvObjList = new List<GameObject>();

    public float tileSize = 1f; // �^�C���̃T�C�Y

    [MenuItem("Custom tools/Read CSV File")]
    static void Init()
    {
        EditorCSVCreate window = (EditorCSVCreate)EditorWindow.GetWindow(typeof(EditorCSVCreate));
        window.Show();
    }

    void OnGUI()
    {
        GUILayout.Label("CSV Folder Selection", EditorStyles.boldLabel);
        folderPath = EditorGUILayout.TextField("Folder Path", folderPath);

        if (GUILayout.Button("Select CSV File"))
        {
            string filePath = EditorUtility.OpenFilePanel("Select CSV File", folderPath, "csv");
            if (!string.IsNullOrEmpty(filePath))
            {
                folderPath = Path.GetDirectoryName(filePath);
                csvFileName = Path.GetFileName(filePath);

                
            }
        }
        GUILayout.Space(20);

        // �^�C���̃v���n�u��I������GUI
        GUILayout.Label("Tile Prefabs", EditorStyles.boldLabel);
        for (int i = 0; i < csvObjList.Count; i++)
        {
            csvObjList[i] = EditorGUILayout.ObjectField("Tile Prefab " + i, csvObjList[i], typeof(GameObject), false) as GameObject;
        }
        if (GUILayout.Button("Add Tile Prefab"))
        {
            csvObjList.Add(null); // �V�����^�C���v���n�u��ǉ�����
        }
        if (GUILayout.Button("Remove Last Tile Prefab"))
        {
            if (csvObjList.Count > 0)
            {
                csvObjList.RemoveAt(csvObjList.Count - 1); // �Ō�̃^�C���v���n�u���폜����
            }
        }

        if (GUILayout.Button("Load Map"))
        {
            LoadMap();
        }

        GUILayout.Space(20);

        if (GUILayout.Button("Delete Map"))
        {
            DeleteMap();
        }
    }

    void LoadMap()
    {
        // CSV�t�@�C����ǂݍ���Ń}�b�v�𐶐����鏈��
        string filePath = Path.Combine(folderPath, csvFileName);

        if (File.Exists(filePath))
        {
            // �}�b�v�̃f�[�^��ǂݍ���
            string[] lines = File.ReadAllLines(filePath);
            int rowCount = lines.Length;
            int colCount = lines[0].Split(',').Length;

            // �}�b�v�𐶐�����
            mapObject = new GameObject("Map");
            for (int row = 0; row < rowCount; row++)
            {
                string[] rowData = lines[row].Split(',');
                for (int col = 0; col < colCount; col++)
                {
                    if (rowData[col] == "") continue; // ��̏ꍇ�̓X�L�b�v
                    int tileIndex = int.Parse(rowData[col]);
                    if (tileIndex >= 0 && tileIndex < csvObjList.Count)
                    {
                        GameObject tilePrefab = csvObjList[tileIndex];
                        if (tilePrefab != null)
                        {
                            Vector3 position = new Vector3(col, 0, -row);
                            GameObject tileObject = PrefabUtility.InstantiatePrefab(tilePrefab) as GameObject;
                            tileObject.transform.position = position;
                            tileObject.transform.parent = mapObject.transform;
                        }
                    }
                }
            }
        }
        else
        {
            Debug.LogError("CSV�t�@�C����������܂���: " + filePath);
        }

    }

    void DeleteMap()
    {
        if (mapObject != null)
        {
            DestroyImmediate(mapObject);
            Debug.Log("Map deleted.");
        }
        else
        {
            Debug.Log("Map does not exist.");
        }
    }
}
