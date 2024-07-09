using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

public class MapCreate : MonoBehaviour
{
    // CSV�t�@�C���ϐ�
    [SerializeField] private string csvFile;

    // �I�u�W�F�N�g�ԍ��z��
    [SerializeField]
    List<GameObject> csvObjList = new List<GameObject>();

    public float tileSize = 1f; // �^�C���̃T�C�Y

    // Start is called before the first frame update
    void Start()
    {
        // CSV�t�@�C���̃p�X���擾
        string filePath = Path.Combine(Application.dataPath, csvFile);

        // CSV�t�@�C�������݂��邩���m�F
        if (File.Exists(filePath))
        {
            // CSV�t�@�C���̓��e��ǂݍ���
            string[] lines = File.ReadAllLines(filePath);

            // �s���Ƃɏ���
            for (int y = 0; y < lines.Length; y++)
            {
                string[] values = lines[y].Split(',');

                // �񂲂Ƃɏ���
                for (int x = 0; x < values.Length; x++)
                {
                    if (values[x] == "") continue; // ��̏ꍇ�̓X�L�b�v
                    int tileIndex = int.Parse(values[x]);


                    // �Ή�����^�C���̃v���n�u�����݂��邩�m�F
                    if (tileIndex >= 0 && tileIndex < csvObjList.Count&& csvObjList[tileIndex] != null)
                    {
                        // �^�C���̈ʒu���v�Z
                        Vector3 tilePosition = new Vector3(x * tileSize, 0f, -y * tileSize);

                        // �^�C���𐶐�
                        GameObject tile = Instantiate(csvObjList[tileIndex], tilePosition, Quaternion.identity);
                        if (tile == null) continue;
                        tile.transform.SetParent(transform); // �}�b�v�̎q�I�u�W�F�N�g�ɐݒ�

                    }
                }
            }
        }
        else
        {
            Debug.LogError("CSV�t�@�C����������܂���: " + filePath);
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
