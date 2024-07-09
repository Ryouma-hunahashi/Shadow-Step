using System.Collections.Generic;
using UnityEngine;

public class LightTest : MonoBehaviour
{
    Mesh mesh;
    //[SerializeField]
    MeshFilter filter;
    // �����I�u�W�F�N�g
    [SerializeField]
    List<GameObject> lightObjects = new List<GameObject>();
    // �ǂɐݒ肵�Ă��郌�C���[
    [SerializeField]
    LayerMask layerMask;
    // ���_���i�[�plist
    private List<Vector3> verticesList;
    private List<Color> colorList;
    [SerializeField]
    int vertexNum;
    void Start()
    {
        // MeshFilter���擾����Mesh���擾����
        filter = GetComponent<MeshFilter>();
        mesh = filter.mesh;

        // ���_���W��ύX����֐����Ăяo��
        //ModifyVertices();
        if(lightObjects != null)
        {
            Debug.Log("lightobj�����ݒ�");
        }
        verticesList = new List<Vector3>();
        colorList = new List<Color>();
    }

    void CheckClip()
    {
        // ���݂�Mesh�̒��_���W���擾����
        mesh.GetVertices(verticesList);
        vertexNum=verticesList.Count;
        // ���_�J���[List�̃N���A
        colorList.Clear();
        Vector3 vertexPosition;
        int i, j;
        // �e���_���W�ɉ����ĕύX���鏈�����s��
        for ( i = 0; i < verticesList.Count; i++)
        {
            // ���[���h���W�ɕϊ��������_���W���擾
            vertexPosition=transform.TransformPoint(verticesList[i]);
           // ���_���W��������I�u�W�F�N�g�ɂނ���Ray���΂�
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
        // �ύX�������_�J���[��Mesh�ɓK�p����
        mesh.SetColors(colorList);
    }
    void Update()
    {
        CheckClip();
    }
}
