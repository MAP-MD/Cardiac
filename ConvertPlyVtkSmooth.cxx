#include <vtkSmartPointer.h>
#include <vtkPolyData.h>
#include <vtkPolyDataWriter.h>
#include <vtkPLYReader.h>
#include <vtkSmoothPolyDataFilter.h>
#include <vtkPolyDataNormals.h>

int main(int argc, char *argv[])
{
    if(argc < 3)
    {
        std::cerr << "Required arguments: input.ply output.vtk" << std::endl;
        return EXIT_FAILURE;
    }
    
    std::string inputFileName = argv[1];
    std::string outputFileName = argv[2];
    
    // Read in PLY file
    vtkSmartPointer<vtkPLYReader> reader = vtkSmartPointer<vtkPLYReader>::New();
    reader->SetFileName(inputFileName.c_str());
    reader->Update();
    
    // Smooth the mesh
    vtkSmartPointer<vtkSmoothPolyDataFilter> smoother = vtkSmartPointer<vtkSmoothPolyDataFilter>::New();
    smoother->SetInputConnection(reader->GetOutputPort());
    smoother->SetNumberOfIterations(300);
    
    // Generate surface normals
    vtkSmartPointer<vtkPolyDataNormals> normals = vtkSmartPointer<vtkPolyDataNormals>::New();
    normals->SetInputConnection(smoother->GetOutputPort());
    normals->FlipNormalsOn();
    
    // Write out to VTK
    vtkSmartPointer<vtkPolyDataWriter> writer = vtkSmartPointer<vtkPolyDataWriter>::New();
    writer->SetFileName(outputFileName.c_str());
    writer->SetInputConnection(normals->GetOutputPort());
    writer->Update();
    
    return EXIT_SUCCESS;
}


