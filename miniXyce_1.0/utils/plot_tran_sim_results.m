function out = plot_tran_sim_results(ckt_name)

    % look for files of the form tran_sim_results_part_<pid+1>.txt
    % plot the results in them
    
    h1 = figure();
    M1 = {};
        
    h2 = figure();
    M2 = {};
    
    pid = 0;
    
    i = 0;

    M = importdata([ckt_name '_tran_results_part_' num2str(pid+1) '.prn'],'\t',1);
    
    figure(h1);
    
    for j = 2:1:size(M.data,2)-2
        plot(M.data(:,1),M.data(:,j),'LineWidth',3);
        i = i+1;
        hold all;
        M1 = [M1 strcat(M.colheaders(1,j),'(t)')];
    end

    figure(h2);

    stairs(M.data(:,1),M.data(:,size(M.data,2)-1),'LineWidth',3);
    hold all;
    M2 = [M2 'GMRES(k) iters'];

    stairs(M.data(:,1),M.data(:,size(M.data,2)),'LineWidth',3);           
    M2 = [M2 'GMRES(k) restarts'];

    pid = pid + 1;
        
    while true

        try

            M = importdata([ckt_name '_tran_results_part_' num2str(pid+1) '.prn'],'\t',1);

        catch

            figure(h1);
            legend(M1,'FontSize',14);
            title('Parallel MiniXyce Simulation Results','FontSize',20);
            xlabel('Time','FontSize',14);
            ylabel('State Variables','FontSize',14);

            figure(h2);
            legend(M2,'FontSize',14);
            title('Parallel MiniXyce Simulation Performance','FontSize',20);
            xlabel('Time','FontSize',14);
            ylabel('GMRES Convergence Parameters','FontSize',14); 

            return;

        end

        figure(h1);

        for j = 2:1:size(M.data,2)
            plot(M.data(:,1),M.data(:,j),'LineWidth',3);
            i = i+1;
            hold all;
            M1 = [M1 strcat(M.colheaders(1,j), '(t)')];
        end

        pid = pid + 1;

    end

end
