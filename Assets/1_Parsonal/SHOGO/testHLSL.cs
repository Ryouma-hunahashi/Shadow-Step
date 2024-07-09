using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class testHLSL : MonoBehaviour
{
    [SerializeField] Camera[] _camera = new Camera[2];
    [SerializeField] int[] _propertyID = new int[2];
    [SerializeField] Camera _mainCamera;
    [SerializeField] Texture _noLightTexture;
    [SerializeField]int _useHDRColor=0;
    // よくみる普通のカラーピッカー
    [SerializeField] private Color _color;

    // HDRカラーピッカー
    [ColorUsage(false, true), SerializeField] private Color _hdrColor;

    // Alpha(透明度)付きのカラーピッカー
    [ColorUsage(true, true), SerializeField] private Color _hdrColorWithAlpha;
    Matrix4x4 _matrix;
    Matrix4x4 _matrix2;
    Matrix4x4 _matrix3;
    Matrix4x4 _matrix4;
    Matrix4x4 _matrix5;
    GameObject _gameObject;
    [SerializeField] Vector3 _position;
    Material _material;

    
    // Start is called before the first frame update
    void Start()
    {
        _camera = new Camera[2];
        
        _matrix3.SetRow(0, new Vector4(0.5f, 0.0f, 0.0f, 0.5f));
        _matrix3.SetRow(1, new Vector4(0.0f, 0.5f, 0.0f, 0.5f));
        _matrix3.SetRow(2, new Vector4(0.0f, 0.0f, 1.0f, 0.0f));
        _matrix3.SetRow(3, new Vector4(0.0f, 0.0f, 0.0f, 1.0f));
        _material = this.GetComponent<MeshRenderer>().material;

        for (int i = 0; i < _propertyID.Length; i++)
        {
            _propertyID[i] = _material.shader.GetPropertyNameId(i);
        }
        //_noLightTexture = _material.GetTexture(_propertyID[0]);


    }

    // Update is called once per frame
    void Update()
    {

        //_material.SetInt("_UseHDR", _useHDRColor);
        //_material.SetColor("_Color", _color);
        //_material.SetColor("_HDRColor",_hdrColor);
        if (_camera[0] != null)
        {
            _matrix = _camera[0].worldToCameraMatrix;
            _matrix2 = GL.GetGPUProjectionMatrix(_camera[0].projectionMatrix, false);
            
        }
        //_position=_matrix.MultiplyPoint3x4(_gameObject.transform.position);
        //_position=_matrix2.MultiplyPoint3x4(_position);
        _matrix4 = _matrix3 * _matrix2 * _matrix;
        //_matrix4 = _matrix * _matrix2 * _matrix3;
        _position = _matrix4.MultiplyPoint3x4(this.transform.position);
        _material.SetMatrix("_lightMatrix", _matrix4);


        //if (_camera[1] != null)
        //{
        //    _matrix = _camera[1].worldToCameraMatrix;
        //    _matrix2 = GL.GetGPUProjectionMatrix(_camera[1].projectionMatrix, false);
        //}
        _matrix4 = _matrix3 * _matrix2 * _matrix;
        _material.SetMatrix("_LightMatrix_2", _matrix4);
        _matrix5 = _material.GetMatrix("_lightMatrix");

        if (_camera[0] != null)
        {
            _material.SetVector("_lightPos", _camera[0].transform.position);
            _material.SetVector("_lightVector", _camera[0].transform.forward);
            _material.SetVector("_cameraPos",_mainCamera.transform.position);
        }
    }

    private void LateUpdate()
    {

    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Light"))
        {
            int nunNum = -1;
            for (int i = 0; i < _camera.Length; i++)
            {
                if (nunNum == -1 && _camera[i] == null)
                {
                    nunNum = i;
                    continue;
                }
                if (_camera[i] != null && _camera[i].transform == other.transform)
                {
                    return;
                }
            }
            if (nunNum != -1)
            {
                //_camera[nunNum] = other.transform.parent.GetChild(0).GetComponent<Camera>();
                _camera[nunNum] = other.GetComponent<Camera>();
                // カメラからレンダーテクスチャを取得する
                //_material.SetTexture(_propertyID[nunNum], _camera[nunNum].targetTexture);

            }
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.CompareTag("Light"))
        {
            for (int i = 0; i < _camera.Length; i++)
            {
                if (_camera[i] == other.GetComponent<Camera>())
                //if(_camera[i].transform==other.transform)
                {
                    _camera[i] = null;
                    //_material.SetTexture(_propertyID[i], _noLightTexture);
                }
            }
        }

    }
}

