using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class _materialManager : MonoBehaviour
{
    // Start is called before the first frame update
    [SerializeField]Camera _mainCamera;
    [SerializeField]Camera _lightCamera;
    [SerializeField]List<GameObject> _materials = new List<GameObject>();
    List<Material> _materials2 = new List<Material>();
    [SerializeField] Vector4 _fogParameter;
    [SerializeField] Vector3 _cameraParameter;
    [SerializeField] float _MaxRayLength;
    [SerializeField] float _threshold;
    //[SerializeField] float _g;
    //[SerializeField] float _raySpeed;
    [SerializeField] int _useHDRColor;
    [SerializeReference] Color _color;
    [ColorUsage(false, true), SerializeField] private Color _hdrColor;
    [SerializeField] Texture2D _noiseTexture;
    int[] _propertyID = new int[13];
    Matrix4x4 _matrix;
    Matrix4x4 _matrix2;
    Matrix4x4 _matrix3;

    void Start()
    {
        for(int i=0; i < _materials.Count; i++)
        {
            _materials2.Add(_materials[i].GetComponent<MeshRenderer>().material);
        }
        _matrix3.SetRow(0, new Vector4(0.5f, 0.0f, 0.0f, 0.5f));
        _matrix3.SetRow(1, new Vector4(0.0f, 0.5f, 0.0f, 0.5f));
        _matrix3.SetRow(2, new Vector4(0.0f, 0.0f, 1.0f, 0.0f));
        _matrix3.SetRow(3, new Vector4(0.0f, 0.0f, 0.0f, 1.0f));
        for (int i = 0; i < _propertyID.Length; i++)
        {
            _propertyID[i] = _materials2[0].shader.GetPropertyNameId(i);
        }



    }

    private void OnDestroy()
    {
        for( int i = 0; i < _materials2.Count; i++)
        {
            Destroy(_materials2[i]);    
        }
    }

    // Update is called once per frame
    void Update()
    {
        _matrix = _lightCamera.worldToCameraMatrix;
        _matrix2 = GL.GetGPUProjectionMatrix(_lightCamera.projectionMatrix, false);

        _cameraParameter.x = _lightCamera.farClipPlane;
        _cameraParameter.y = _lightCamera.nearClipPlane;
        _cameraParameter.z = _lightCamera.orthographicSize;
        for (int j = 0; j < _materials2.Count; j++)
        {

            //_materials2[j].SetFloat("_raySpeed", _raySpeed);
            //_materials2[j].SetFloat("_g", _g);
            _materials2[j].SetColor("_Color", _color);
            _materials2[j].SetColor("_HDRColor", _hdrColor);
            _materials2[j].SetInt("_UseHDR", _useHDRColor);
            _materials2[j].SetVector("_cameraPos", _mainCamera.transform.position);
            _materials2[j].SetVector("_lightPos", _lightCamera.transform.position);
            _materials2[j].SetVector("_forward", _lightCamera.transform.forward);
            _materials2[j].SetVector("_right", _lightCamera.transform.right);
            _materials2[j].SetVector("_up", _lightCamera.transform.up);
            _materials2[j].SetVector("_lightParameter", _cameraParameter);
            _materials2[j].SetVector("_fogParameter", _fogParameter);
            _materials2[j].SetMatrix("_lightMatrix", _matrix3 * _matrix2 * _matrix);
            _materials2[j].SetFloat("_MaxRayLength", _MaxRayLength);
            _materials2[j].SetFloat("_threshold", _threshold);
            _materials2[j].SetTexture("_NoiseTexture", _noiseTexture);
            //_materials2[j].SetColor(_propertyID[0], _color);
            //_materials2[j].SetColor(_propertyID[1], _hdrColor);
            //_materials2[j].SetInt(_propertyID[2], _useHDRColor);
            //_materials2[j].SetVector(_propertyID[3], _mainCamera.transform.position);
            //_materials2[j].SetVector(_propertyID[4], _lightCamera.transform.position);
            //_materials2[j].SetVector(_propertyID[5], _lightCamera.transform.forward);
            //_materials2[j].SetVector(_propertyID[6], _lightCamera.transform.right);
            //_materials2[j].SetVector(_propertyID[7], _lightCamera.transform.up);
            //_materials2[j].SetVector(_propertyID[8], _cameraParameter);
            //_materials2[j].SetVector(_propertyID[9], _fogParameter);
            //_materials2[j].SetMatrix(_propertyID[10], _matrix3 * _matrix2 * _matrix);
            //_materials2[j].SetFloat(_propertyID[11], _MaxRayLength);
            //_materials2[j].SetFloat(_propertyID[12], _threshold);
        }

    }
}
